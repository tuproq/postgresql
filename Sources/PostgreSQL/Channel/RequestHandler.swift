import Crypto
import Foundation
import Logging
import NIOCore

final class RequestHandler: ChannelDuplexHandler {
    typealias InboundIn = Message
    typealias OutboundIn = Request
    typealias OutboundOut = Message

    let connection: PostgreSQL
    private var request: Request?
    private var firstError: Error?
    /// True while we are waiting for the single-byte SSL response (which has no
    /// length prefix and whose byte value collides with other message identifiers).
    private var isAwaitingSSLResponse = false
    /// Preserved between AuthenticationSASL and AuthenticationSASLContinue so we
    /// can supply the client-first-message-bare when building the client proof.
    private var scramState: SCRAMState?

    /// Transient state kept between the two SCRAM-SHA-256 round-trips.
    private struct SCRAMState {
        let username: String
        let password: String
        let clientNonce: String
        let clientFirstMessageBare: String
    }

    init(connection: PostgreSQL) {
        self.connection = connection
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var message = unwrapInboundIn(data)
        var buffer = message.buffer

        // The SSL response is a raw single byte ('S' or 'N') with no length prefix.
        // Its identifier byte value (0x53 / 0x4E) collides with parameterStatus /
        // noticeResponse, so we must intercept it before the type-based switch.
        if isAwaitingSSLResponse {
            isAwaitingSSLResponse = false
            request?.promise.succeed(Response(message: message))
            request = nil
            return
        }

        switch message.identifier {
        case .authentication:
            // Parse the server's authentication challenge and respond in-band.
            // The promise must NOT be resolved here — ReadyForQuery is always the
            // terminal signal that ends a request/response cycle.
            do {
                let auth = try Message.Authentication(buffer: &buffer)
                switch auth.kind {

                case .ok:
                    // Server accepted our credentials; wait for ReadyForQuery.
                    break

                case .cleartext:
                    let password = connection.configuration.password ?? ""
                    sendInband(Message.Password(password), context: context)

                case .md5(let salt):
                    let username = connection.configuration.username ?? ""
                    let password = connection.configuration.password ?? ""
                    let hash = md5AuthHash(password: password, username: username, salt: salt)
                    sendInband(Message.Password("md5\(hash)"), context: context)

                case .sasl(let mechanisms):
                    guard mechanisms.contains("SCRAM-SHA-256") else {
                        setError(PostgreSQLError(
                            "No supported SASL mechanism. Server offered: \(mechanisms.joined(separator: ", "))"
                        ))
                        break
                    }
                    let username = connection.configuration.username ?? ""
                    let password = connection.configuration.password ?? ""
                    let state = makeSCRAMState(username: username, password: password)
                    scramState = state
                    let clientFirstMessage = "n,,\(state.clientFirstMessageBare)"
                    sendInband(
                        Message.SASLInitialResponse(
                            mechanism: "SCRAM-SHA-256",
                            initialResponse: Array(clientFirstMessage.utf8)
                        ),
                        context: context
                    )

                case .saslContinue(let data):
                    guard let state = scramState,
                          let serverFirst = String(bytes: data, encoding: .utf8) else {
                        setError(PostgreSQLError("SCRAM: invalid server-first message"))
                        break
                    }
                    scramState = nil
                    do {
                        let clientFinal = try computeSCRAMClientFinal(
                            state: state,
                            serverFirst: serverFirst
                        )
                        sendInband(Message.SASLResponse(data: Array(clientFinal.utf8)), context: context)
                    } catch {
                        setError(error)
                    }

                case .saslFinal:
                    // Optionally verify the server signature here. For now we trust
                    // the server and wait for AuthenticationOk followed by ReadyForQuery.
                    break

                case .unsupported(let rawValue):
                    setError(PostgreSQLError(
                        "Authentication method \(rawValue) is not supported."
                    ))
                }
            } catch {
                connection.logger.error("\(error)")
            }
        case .parameterStatus:
            do {
                let parameterStatus = try Message.ParameterStatus(buffer: &buffer)
                connection.serverParameters[parameterStatus.name] = parameterStatus.value
            } catch {
                connection.logger.error("\(error)")
            }
        case .backendKeyData:
            do {
                connection.backendKeyData = try Message.BackendKeyData(buffer: &buffer)
            } catch {
                connection.logger.error("\(error)")
            }
        case .rowDescription:
            do {
                let rowDescription = try Message.RowDescription(buffer: &message.buffer)
                request?.results.append(Result(columns: rowDescription.columns))
            } catch {
                connection.logger.error("\(error)")
            }
        case .dataRow:
            do {
                let dataRow = try Message.DataRow(buffer: &message.buffer)

                if let result = request?.results.last {
                    var row = [PostgreSQLCodable?]()

                    for (index, buffer) in dataRow.values.enumerated() {
                        var buffer = buffer
                        let column = result.columns[index]
                        row.append(try decode(from: &buffer, to: column))
                    }

                    result.rows.append(row)
                }
            } catch {
                connection.logger.error("\(error)")
            }
        case .readyForQuery:
            if let error = firstError {
                request?.promise.fail(error)
            } else {
                do {
                    let readyForQuery = try Message.ReadyForQuery(buffer: &buffer)

                    switch readyForQuery.status {
                    case .idle:
                        let response = Response(message: message, results: request?.results ?? .init())
                        request?.promise.succeed(response)
                    case .transaction:
                        let response = Response(message: message, results: request?.results ?? .init())
                        request?.promise.succeed(response)
                    case .transactionFailed:
                        request?.promise.succeed(Response(message: message))
                    }
                } catch {
                    connection.logger.error("\(error)")
                }
            }

            request = nil
            firstError = nil
        case .errorResponse:
            do {
                let errorResponse = try Message.ErrorResponse(buffer: &buffer)
                let message = errorResponse.fields[.message] ?? "An unknown error."
                let error = PostgreSQLError(message)
                setError(error)
            } catch {
                connection.logger.error("\(error)")
            }
        case .noticeResponse:
            do {
                let noticeResponse = try Message.NoticeResponse(buffer: &buffer)
                let message = noticeResponse.fields[.message] ?? "An unknown warning."
                connection.logger.warning("\(message)")
            } catch {
                connection.logger.error("\(error)")
            }
        default:
            break
        }
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let request = unwrapOutboundIn(data)
        self.request = request
        isAwaitingSSLResponse = request.messages.first?.identifier == .sslRequest

        for message in request.messages {
            context.write(wrapOutboundOut(message), promise: promise)
        }
    }

    /// Write and flush a single frontend message directly on the channel without
    /// going through the normal Request machinery (no promise involved). Used to
    /// send mid-handshake responses (e.g. password) that are part of an ongoing
    /// request/response cycle rather than a new top-level request.
    private func sendInband<T: MessageType>(_ type: T, context: ChannelHandlerContext) {
        var buf = context.channel.allocator.buffer(capacity: 64)
        type.encode(into: &buf)
        let msg = Message(identifier: type.identifier, source: .frontend, buffer: buf)
        context.writeAndFlush(wrapOutboundOut(msg), promise: nil)
    }

    private func decode(from buffer: inout ByteBuffer?, to column: Column) throws -> PostgreSQLCodable? {
        if var buffer = buffer {
            let format = column.dataFormat
            let type = column.dataTypeID

            switch type {
            case .bool: return try Bool(buffer: &buffer, format: format, type: type)
            case .bytea: return try Data(buffer: &buffer, format: format, type: type)
            case .char: return try UInt8(buffer: &buffer, format: format, type: type)
            case .float4: return try Float(buffer: &buffer, format: format, type: type)
            case .float8: return try Double(buffer: &buffer, format: format, type: type)
            case .int2: return try Int16(buffer: &buffer, format: format, type: type)
            case .int4, .oid: return try Int32(buffer: &buffer, format: format, type: type)
            case .int8: return try Int64(buffer: &buffer, format: format, type: type)
            case .name: return try String(buffer: &buffer, format: format, type: type)
            case .numeric: return try Decimal(buffer: &buffer, format: format, type: type)
            case .timestamp, .timestamptz, .date: return try Date(buffer: &buffer, format: format, type: type)
            case .uuid: return try UUID(buffer: &buffer, format: format, type: type)
            case .varchar, .text:
                do {
                    return try UUID(buffer: &buffer, format: format, type: type)
                } catch {
                    return try String(buffer: &buffer, format: format, type: type)
                }
            default: return buffer.readString()
            }
        }

        return nil
    }

    private func setError(_ error: Error) {
        if firstError == nil {
            firstError = error
        }
    }

    // MARK: - Authentication helpers

    /// Build the MD5 password hash expected by PostgreSQL:
    ///   "md5" + hex(MD5(hex(MD5(password + username)) + salt))
    private func md5AuthHash(password: String, username: String, salt: [UInt8]) -> String {
        // Step 1: MD5(password_bytes + username_bytes) → hex string
        let step1Input = Array(password.utf8) + Array(username.utf8)
        let step1Digest = Insecure.MD5.hash(data: step1Input)
        let step1Hex = step1Digest.map { String(format: "%02x", $0) }.joined()

        // Step 2: MD5(step1_hex_bytes + raw_salt_bytes) → hex string
        let step2Input = Array(step1Hex.utf8) + salt
        let step2Digest = Insecure.MD5.hash(data: step2Input)
        return step2Digest.map { String(format: "%02x", $0) }.joined()
    }

    /// Create initial SCRAM-SHA-256 state with a freshly generated client nonce.
    /// The nonce is 24 random bytes encoded as base64, which produces only
    /// printable ASCII characters and no commas — safe to embed in SCRAM messages.
    private func makeSCRAMState(username: String, password: String) -> SCRAMState {
        // Generate a cryptographically random 24-byte nonce.
        var rng = SystemRandomNumberGenerator()
        let nonceBytes = (0..<24).map { _ in UInt8.random(in: .min ... .max, using: &rng) }
        let clientNonce = Data(nonceBytes).base64EncodedString()

        // RFC 5802: ',' and '=' in the username must be escaped.
        let safeUsername = username
            .replacingOccurrences(of: "=", with: "=3D")
            .replacingOccurrences(of: ",", with: "=2C")
        let clientFirstMessageBare = "n=\(safeUsername),r=\(clientNonce)"

        return SCRAMState(
            username: username,
            password: password,
            clientNonce: clientNonce,
            clientFirstMessageBare: clientFirstMessageBare
        )
    }

    /// Compute the SCRAM-SHA-256 client-final-message (including the proof)
    /// given the client state and the server-first-message.
    ///
    /// SCRAM-SHA-256 (RFC 5802):
    ///   SaltedPassword = PBKDF2-SHA256(password, salt, iterations)
    ///   ClientKey      = HMAC(SaltedPassword, "Client Key")
    ///   StoredKey      = SHA256(ClientKey)
    ///   AuthMessage    = client-first-bare + "," + server-first + "," + client-final-without-proof
    ///   ClientProof    = ClientKey XOR HMAC(StoredKey, AuthMessage)
    private func computeSCRAMClientFinal(state: SCRAMState, serverFirst: String) throws -> String {
        // --- Parse server-first-message ---
        var serverNonce: String?
        var saltBase64: String?
        var iterations: Int?

        for part in serverFirst.split(separator: ",", omittingEmptySubsequences: false) {
            let attribute = String(part)
            if attribute.hasPrefix("r=") { serverNonce = String(attribute.dropFirst(2)) }
            else if attribute.hasPrefix("s=") { saltBase64 = String(attribute.dropFirst(2)) }
            else if attribute.hasPrefix("i=") { iterations = Int(attribute.dropFirst(2)) }
        }

        guard let serverNonce,
              serverNonce.hasPrefix(state.clientNonce),
              let saltBase64,
              let saltData = Data(base64Encoded: saltBase64),
              let iterations, iterations > 0 else {
            throw PostgreSQLError("SCRAM: malformed server-first-message")
        }

        let salt = [UInt8](saltData)
        let passwordBytes = Array(state.password.utf8)

        // --- Derive keys ---
        let saltedPasswordBytes = pbkdf2SHA256(password: passwordBytes, salt: salt, iterations: iterations)
        let saltedKey = SymmetricKey(data: saltedPasswordBytes)

        let clientKey = [UInt8](HMAC<SHA256>.authenticationCode(
            for: Array("Client Key".utf8), using: saltedKey))
        let storedKey = [UInt8](SHA256.hash(data: clientKey))
        let storedSymKey = SymmetricKey(data: storedKey)

        // --- Build auth message ---
        // GS2 header "n,," base64-encoded = "biws" (no channel binding)
        let clientFinalWithoutProof = "c=biws,r=\(serverNonce)"
        let authMessage = "\(state.clientFirstMessageBare),\(serverFirst),\(clientFinalWithoutProof)"

        // --- Compute proof ---
        let clientSignature = [UInt8](HMAC<SHA256>.authenticationCode(
            for: Array(authMessage.utf8), using: storedSymKey))
        let clientProof = zip(clientKey, clientSignature).map { keyByte, signatureByte in keyByte ^ signatureByte }
        let clientProofBase64 = Data(clientProof).base64EncodedString()

        return "\(clientFinalWithoutProof),p=\(clientProofBase64)"
    }

    /// PBKDF2-HMAC-SHA256: derives a 32-byte key for a single output block.
    ///
    /// PostgreSQL uses SCRAM with a 32-byte (256-bit) derived key, which fits
    /// exactly in one PBKDF2 block, so the simple one-block implementation below
    /// is correct and avoids pulling in a full PBKDF2 library.
    ///
    /// Formula: U1 = HMAC(password, salt || 0x00000001)
    ///          Ui = HMAC(password, U(i-1))
    ///          T  = U1 XOR U2 XOR … XOR Uiterations
    private func pbkdf2SHA256(password: [UInt8], salt: [UInt8], iterations: Int) -> [UInt8] {
        let hmacKey = SymmetricKey(data: password)
        // Block index 1 appended as a 4-byte big-endian integer.
        let blockSuffix: [UInt8] = [0, 0, 0, 1]
        var currentBlock = [UInt8](HMAC<SHA256>.authenticationCode(for: salt + blockSuffix, using: hmacKey))
        var xorAccumulator = currentBlock
        for _ in 1..<iterations {
            currentBlock = [UInt8](HMAC<SHA256>.authenticationCode(for: currentBlock, using: hmacKey))
            for byteIndex in 0..<xorAccumulator.count {
                xorAccumulator[byteIndex] ^= currentBlock[byteIndex]
            }
        }
        return xorAccumulator
    }
}
