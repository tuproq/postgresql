extension Message {
    struct Identifier: CustomStringConvertible, Equatable, ExpressibleByIntegerLiteral {
        /// Authentication (B)
        static let authentication: Self = 0x52 // 'R'

        /// BackendKeyData (B)
        static let backendKeyData: Self = 0x4B // 'K'

        /// Bind (F)
        static let bind: Self = 0x42 // 'B'

        /// BindComplete (B)
        static let bindComplete: Self = 0x32 // '2'

        /// Close (F)
        static let close: Self = 0x43 // 'C'

        /// CloseComplete (B)
        static let closeComplete: Self = 0x33 // '3'

        /// CommandComplete (B)
        static let commandComplete: Self = 0x43 // 'C'

        /// CopyBothResponse (B)
        static let copyBothResponse: Self = 0x57 // 'W'

        /// CopyData (F & B)
        static let copyData: Self = 0x64 // 'd'

        /// CopyDone (F & B)
        static let copyDone: Self = 0x63 // 'c'

        /// CopyFail (F)
        static let copyFail: Self = 0x66 // 'f'

        /// CopyInResponse (B)
        static let copyInResponse: Self = 0x47 // 'G'

        /// CopyOutResponse (B)
        static let copyOutResponse: Self = 0x48 // 'H'

        /// DataRow (B)
        static let dataRow: Self = 0x44 // 'D'

        /// Describe (F)
        static let describe: Self = 0x44 // 'D'

        /// EmptyQueryResponse (B)
        static let emptyQueryResponse: Self = 0x49 // 'I'

        /// ErrorResponse (B)
        static let errorResponse: Self = 0x45 // 'E'

        /// Execute (F)
        static let execute: Self = 0x45 // 'E'

        /// Flush (F)
        static let flush: Self = 0x48 // 'H'

        /// FunctionCall (F)
        static let functionCall: Self = 0x46 // 'F'

        /// FunctionCallResponse (B)
        static let functionCallResponse: Self = 0x56 // 'V'

        /// GSSResponse (F)
        static let gssResponse: Self = 0x70 // 'p'

        /// NegotiateProtocolVersion (B)
        static let negotiateProtocolVersion: Self = 0x76 // 'v'

        /// NoData (B)
        static let noData: Self = 0x6E // 'n'

        /// NoticeResponse (B)
        static let noticeResponse: Self = 0x4E // 'N'

        /// NotificationResponse (B)
        static let notificationResponse: Self = 0x41 // 'A'

        /// ParameterDescription (B)
        static let parameterDescription: Self = 0x74 // 't'

        /// ParameterStatus (B)
        static let parameterStatus: Self = 0x53 // 'S'

        /// Parse (F)
        static let parse: Self = 0x50 // 'P'

        /// ParseComplete (B)
        static let parseComplete: Self = 0x31 // '1'

        /// Password (F)
        static let password: Self = 0x70 // 'p'

        /// PortalSuspended (B)
        static let portalSuspended: Self = 0x73 // 's'

        /// ReadyForQuery (B)
        static let readyForQuery: Self = 0x5A // 'Z'

        /// RowDescription (B)
        static let rowDescription: Self = 0x54 // 'T'

        /// SASLInitialResponse (F)
        static let saslInitialResponse: Self = 0x70 // 'p'

        /// SASLResponse (F)
        static let saslResponse: Self = 0x70 // 'p'

        /// SimpleQuery (F)
        static let simpleQuery: Self = 0x51 // 'Q'

        /// SSLRequest (F)
        static let sslRequest: Self = 0x00

        /// SSL Response (B)
        static let sslSupported: Self = 0x53 // 'S'

        /// SSL Response (B)
        static let sslUnsupported: Self = 0x4E // 'N'

        /// StartupMessage (F)
        static let startupMessage: Self = 0x00

        /// Sync (F)
        static let sync: Self = 0x53 // 'S'

        /// Terminate (F)
        static let terminate: Self = 0x58 // 'X'

        let value: UInt8
        var description: String { "\(Character(Unicode.Scalar(value)))" }

        init(integerLiteral value: UInt8) {
            self.value = value
        }
    }
}
