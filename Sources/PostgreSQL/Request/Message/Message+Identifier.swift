extension Message {
    enum Identifier: CustomStringConvertible, Equatable, ExpressibleByIntegerLiteral {
        /// Authentication (B)
        case authentication // 'R'

        /// BackendKeyData (B)
        case backendKeyData // 'K'

        /// Bind (F)
        case bind // 'B'

        /// BindComplete (B)
        case bindComplete // '2'

        /// Close (F)
        case close // 'C'

        /// CloseComplete (B)
        case closeComplete // '3'

        /// CommandComplete (B)
        case commandComplete // 'C'

        /// CopyBothResponse (B)
        case copyBothResponse // 'W'

        /// CopyData (F & B)
        case copyData // 'd'

        /// CopyDone (F & B)
        case copyDone // 'c'

        /// CopyFail (F)
        case copyFail // 'f'

        /// CopyInResponse (B)
        case copyInResponse // 'G'

        /// CopyOutResponse (B)
        case copyOutResponse // 'H'

        /// DataRow (B)
        case dataRow // 'D'

        /// Describe (F)
        case describe // 'D'

        /// EmptyQueryResponse (B)
        case emptyQueryResponse // 'I'

        /// ErrorResponse (B)
        case errorResponse // 'E'

        /// Execute (F)
        case execute // 'E'

        /// Flush (F)
        case flush // 'H'

        /// FunctionCall (F)
        case functionCall // 'F'

        /// FunctionCallResponse (B)
        case functionCallResponse // 'V'

        /// GSSENCRequest (F)
        case gssenCRequest

        /// GSSResponse (F)
        case gssResponse // 'p'

        /// NegotiateProtocolVersion (B)
        case negotiateProtocolVersion // 'v'

        /// NoData (B)
        case noData // 'n'

        /// None
        case none

        /// NoticeResponse (B)
        case noticeResponse // 'N'

        /// NotificationResponse (B)
        case notificationResponse // 'A'

        /// ParameterDescription (B)
        case parameterDescription // 't'

        /// ParameterStatus (B)
        case parameterStatus // 'S'

        /// Parse (F)
        case parse // 'P'

        /// ParseComplete (B)
        case parseComplete // '1'

        /// Password (F)
        case password // 'p'

        /// PortalSuspended (B)
        case portalSuspended // 's'

        /// Query (F)
        case query // 'Q'

        /// ReadyForQuery (B)
        case readyForQuery // 'Z'

        /// RowDescription (B)
        case rowDescription // 'T'

        /// SASLInitialResponse (F)
        case saslInitialResponse // 'p'

        /// SASLResponse (F)
        case saslResponse // 'p'

        /// SSLRequest (F)
        case sslRequest

        /// Startup (F)
        case startup

        /// Sync (F)
        case sync // 'S'

        /// Terminate (F)
        case terminate // 'X'

        /// Raw value
        var value: UInt8? {
            switch self {
            case .authentication: return 0x52
            case .backendKeyData: return 0x4B
            case .bind: return 0x42
            case .bindComplete: return 0x32
            case .close: return 0x43
            case .closeComplete: return 0x33
            case .commandComplete: return 0x43
            case .copyBothResponse: return 0x57
            case .copyData: return 0x64
            case .copyDone: return 0x63
            case .copyFail: return 0x66
            case .copyInResponse: return 0x47
            case .copyOutResponse: return 0x48
            case .dataRow: return 0x44
            case .describe: return 0x44
            case .emptyQueryResponse: return 0x49
            case .errorResponse: return 0x45
            case .execute: return 0x45
            case .flush: return 0x48
            case .functionCall: return 0x46
            case .functionCallResponse: return 0x56
            case .gssenCRequest: return nil
            case .gssResponse: return 0x70
            case .negotiateProtocolVersion: return 0x76
            case .noData: return 0x6E
            case .none: return nil
            case .noticeResponse: return 0x4E
            case .notificationResponse: return 0x41
            case .parameterDescription: return 0x74
            case .parameterStatus: return 0x53
            case .parse: return 0x50
            case .parseComplete: return 0x31
            case .password: return 0x70
            case .portalSuspended: return 0x73
            case .query: return 0x51
            case .readyForQuery: return 0x5A
            case .rowDescription: return 0x54
            case .saslInitialResponse: return 0x70
            case .saslResponse: return 0x70
            case .sslRequest,
                 .startup: return nil
            case .sync: return 0x53
            case .terminate: return 0x58
            }
        }

        var description: String {
            if let value = value {
                return String(Character(Unicode.Scalar(value)))
            }

            return ""
        }

        init(integerLiteral value: UInt8) {
            switch value {
            case 0x52: self = .authentication
            case 0x4B: self = .backendKeyData
            case 0x42: self = .bind
            case 0x32: self = .bindComplete
            case 0x43: self = .close // Other options: .commandComplete
            case 0x33: self = .closeComplete
            case 0x57: self = .copyBothResponse
            case 0x64: self = .copyData
            case 0x63: self = .copyDone
            case 0x66: self = .copyFail
            case 0x47: self = .copyInResponse
            case 0x48: self = .copyOutResponse // Other options: .flush
            case 0x44: self = .dataRow // Other options: .describe
            case 0x49: self = .emptyQueryResponse
            case 0x45: self = .errorResponse // Other options: .execute
            case 0x46: self = .functionCall
            case 0x56: self = .functionCallResponse
            case 0x76: self = .negotiateProtocolVersion
            case 0x6E: self = .noData
            case 0x4E: self = .noticeResponse
            case 0x41: self = .notificationResponse
            case 0x74: self = .parameterDescription
            case 0x53: self = .parameterStatus // Other options: .sync
            case 0x50: self = .parse
            case 0x31: self = .parseComplete
            case 0x73: self = .portalSuspended
            case 0x51: self = .query
            case 0x5A: self = .readyForQuery
            case 0x54: self = .rowDescription
            case 0x70: self = .gssResponse // Other options: .password, .saslInitialResponse, .saslResponse
            case 0x58: self = .terminate
            default: self = .none
            }
        }
    }
}
