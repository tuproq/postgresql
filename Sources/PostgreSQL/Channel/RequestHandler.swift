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
                    // Server accepted the credentials; wait for ReadyForQuery.
                    break
                case .cleartext:
                    let password = connection.configuration.password ?? ""
                    sendInband(Message.Password(password), context: context)
                default:
                    // MD5, SCRAM-SHA-256, etc. are not yet implemented.
                    let error = PostgreSQLError(
                        "Authentication method '\(auth.kind)' is not yet supported."
                    )
                    setError(error)
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
}
