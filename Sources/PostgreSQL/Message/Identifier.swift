extension Message {
    /// A direction-tagged message identifier.
    ///
    /// The PostgreSQL wire protocol reuses the same byte values across the
    /// frontend→backend and backend→frontend directions (e.g. 0x43 means
    /// `Close` when sent by the client but `CommandComplete` when sent by the
    /// server).  Wrapping each direction in its own case makes comparisons
    /// unambiguous at the type level: `.frontend(.close) != .backend(.commandComplete)`
    /// even though both carry the same raw byte.
    enum Identifier: CustomStringConvertible, Equatable {
        case frontend(FrontendIdentifier)
        case backend(BackendIdentifier)

        /// The raw byte value written to or read from the wire.
        var value: UInt8 {
            switch self {
            case .frontend(let frontendIdentifier): return frontendIdentifier.value
            case .backend(let backendIdentifier): return backendIdentifier.value
            }
        }

        var description: String { "\(Character(Unicode.Scalar(value)))" }
    }

    /// Identifiers for messages sent by the client (frontend → backend).
    struct FrontendIdentifier: CustomStringConvertible, Equatable {
        /// Bind (F)
        static let bind: Self = .init(0x42) // 'B'
        /// Close (F)
        static let close: Self = .init(0x43) // 'C'
        /// CopyData (F & B)
        static let copyData: Self = .init(0x64) // 'd'
        /// CopyDone (F & B)
        static let copyDone: Self = .init(0x63) // 'c'
        /// CopyFail (F)
        static let copyFail: Self = .init(0x66) // 'f'
        /// Describe (F)
        static let describe: Self = .init(0x44) // 'D'
        /// Execute (F)
        static let execute: Self = .init(0x45) // 'E'
        /// Flush (F)
        static let flush: Self = .init(0x48) // 'H'
        /// FunctionCall (F)
        static let functionCall: Self = .init(0x46) // 'F'
        /// GSSResponse (F)
        static let gssResponse: Self = .init(0x70) // 'p'
        /// Parse (F)
        static let parse: Self = .init(0x50) // 'P'
        /// Password (F) — shares byte with gssResponse/saslInitialResponse/saslResponse
        static let password: Self = .init(0x70) // 'p'
        /// SASLInitialResponse (F) — shares byte with password
        static let saslInitialResponse: Self = .init(0x70) // 'p'
        /// SASLResponse (F) — shares byte with password
        static let saslResponse: Self = .init(0x70) // 'p'
        /// Query / SimpleQuery (F)
        static let simpleQuery: Self = .init(0x51) // 'Q'
        /// SSLRequest (F) — no type byte on wire
        static let sslRequest: Self = .init(0x00)
        /// StartupMessage (F) — no type byte on wire
        static let startupMessage: Self = .init(0x00)
        /// Sync (F)
        static let sync: Self = .init(0x53) // 'S'
        /// Terminate (F)
        static let terminate: Self = .init(0x58) // 'X'

        let value: UInt8
        var description: String { "\(Character(Unicode.Scalar(value)))" }

        init(_ value: UInt8) { self.value = value }
    }

    /// Identifiers for messages sent by the server (backend → frontend).
    struct BackendIdentifier: CustomStringConvertible, Equatable {
        /// Authentication (B)
        static let authentication: Self = .init(0x52) // 'R'
        /// BackendKeyData (B)
        static let backendKeyData: Self = .init(0x4B) // 'K'
        /// BindComplete (B)
        static let bindComplete: Self = .init(0x32) // '2'
        /// CloseComplete (B)
        static let closeComplete: Self = .init(0x33) // '3'
        /// CommandComplete (B)
        static let commandComplete: Self = .init(0x43) // 'C'
        /// CopyBothResponse (B)
        static let copyBothResponse: Self = .init(0x57) // 'W'
        /// CopyData (F & B)
        static let copyData: Self = .init(0x64) // 'd'
        /// CopyDone (F & B)
        static let copyDone: Self = .init(0x63) // 'c'
        /// CopyInResponse (B)
        static let copyInResponse: Self = .init(0x47) // 'G'
        /// CopyOutResponse (B)
        static let copyOutResponse: Self = .init(0x48) // 'H'
        /// DataRow (B)
        static let dataRow: Self = .init(0x44) // 'D'
        /// EmptyQueryResponse (B)
        static let emptyQueryResponse: Self = .init(0x49) // 'I'
        /// ErrorResponse (B)
        static let errorResponse: Self = .init(0x45) // 'E'
        /// FunctionCallResponse (B)
        static let functionCallResponse: Self = .init(0x56) // 'V'
        /// NegotiateProtocolVersion (B)
        static let negotiateProtocolVersion: Self = .init(0x76) // 'v'
        /// NoData (B)
        static let noData: Self = .init(0x6E) // 'n'
        /// NoticeResponse (B)
        static let noticeResponse: Self = .init(0x4E) // 'N'
        /// NotificationResponse (B)
        static let notificationResponse: Self = .init(0x41) // 'A'
        /// ParameterDescription (B)
        static let parameterDescription: Self = .init(0x74) // 't'
        /// ParameterStatus (B)
        static let parameterStatus: Self = .init(0x53) // 'S'
        /// ParseComplete (B)
        static let parseComplete: Self = .init(0x31) // '1'
        /// PortalSuspended (B)
        static let portalSuspended: Self = .init(0x73) // 's'
        /// ReadyForQuery (B)
        static let readyForQuery: Self = .init(0x5A) // 'Z'
        /// RowDescription (B)
        static let rowDescription: Self = .init(0x54) // 'T'
        /// SSL negotiation response: server supports SSL
        static let sslSupported: Self = .init(0x53) // 'S'
        /// SSL negotiation response: server does not support SSL
        static let sslUnsupported: Self = .init(0x4E) // 'N'

        let value: UInt8
        var description: String { "\(Character(Unicode.Scalar(value)))" }

        init(_ value: UInt8) { self.value = value }
    }
}
