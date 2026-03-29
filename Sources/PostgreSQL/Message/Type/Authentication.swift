extension Message {
    struct Authentication: MessageType {
        let identifier: Identifier = .authentication
        let kind: Kind

        /// Associated-value enum carrying all data the handler needs to respond.
        /// Unknown / unsupported raw kind values are wrapped in `.unsupported` so
        /// the handler can produce a meaningful error rather than silently swallowing
        /// a parse failure.
        enum Kind {
            /// AuthenticationOk — handshake complete; wait for ReadyForQuery.
            case ok
            /// AuthenticationCleartextPassword — send the password verbatim.
            case cleartext
            /// AuthenticationMD5Password — `salt` is the 4-byte server-supplied salt.
            case md5(salt: [UInt8])
            /// AuthenticationSASL — `mechanisms` is the ordered list of mechanism
            /// names the server is willing to accept (e.g. ["SCRAM-SHA-256"]).
            case sasl(mechanisms: [String])
            /// AuthenticationSASLContinue — `data` is the raw server-first-message.
            case saslContinue(data: [UInt8])
            /// AuthenticationSASLFinal — `data` is the server-final-message (verifier).
            case saslFinal(data: [UInt8])
            /// A recognised-but-unimplemented or unknown method.
            case unsupported(Int32)
        }

        init(buffer: inout ByteBuffer) throws {
            guard let rawValue = buffer.readInteger(as: Int32.self) else {
                throw postgreSQLError(.cantParseAuthenticationMethod)
            }
            switch rawValue {
            case 0:
                kind = .ok
            case 3:
                kind = .cleartext
            case 5:
                guard let salt = buffer.readBytes(length: 4) else {
                    throw postgreSQLError(.cantParseAuthenticationMethod)
                }
                kind = .md5(salt: salt)
            case 10:
                // Null-terminated mechanism names, terminated by an empty string.
                var mechanisms = [String]()
                while let name = buffer.readNullTerminatedString(), !name.isEmpty {
                    mechanisms.append(name)
                }
                kind = .sasl(mechanisms: mechanisms)
            case 11:
                let data = buffer.readBytes(length: buffer.readableBytes) ?? .init()
                kind = .saslContinue(data: data)
            case 12:
                let data = buffer.readBytes(length: buffer.readableBytes) ?? .init()
                kind = .saslFinal(data: data)
            default:
                // Covers KerberosV5 (2), SCMCredential (6), GSS (7),
                // GSSContinue (8), SSPI (9), and any future kinds.
                kind = .unsupported(rawValue)
            }
        }
    }
}
