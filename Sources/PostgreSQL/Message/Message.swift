struct Message: CustomStringConvertible, Equatable {
    let identifier: Identifier
    let type: Kind
    var buffer: ByteBuffer

    enum Kind {
        case backend
        case frontend
    }

    enum Command: UInt8 {
        case portal = 0x50 // 'P'
        case statement = 0x53 // 'S'
    }

    var description: String {
        let name: String

        switch identifier {
        case .frontend(let frontendIdentifier):
            switch frontendIdentifier {
            case .bind: name = "Bind"
            case .close: name = "Close"
            case .copyData: name = "CopyData"
            case .copyDone: name = "CopyDone"
            case .copyFail: name = "CopyFail"
            case .describe: name = "Describe"
            case .execute: name = "Execute"
            case .flush: name = "Flush"
            case .functionCall: name = "FunctionCall"
            case .gssResponse: name = "GSSResponse"
            case .parse: name = "Parse"
            case .password: name = "Password"
            case .saslInitialResponse: name = "SASLInitialResponse"
            case .saslResponse: name = "SASLResponse"
            case .simpleQuery: name = "SimpleQuery"
            case .sslRequest: name = "SSLRequest"
            case .startupMessage: name = "StartupMessage"
            case .sync: name = "Sync"
            case .terminate: name = "Terminate"
            default: name = "Unknown(\(frontendIdentifier))"
            }
        case .backend(let backendIdentifier):
            switch backendIdentifier {
            case .authentication: name = "Authentication"
            case .backendKeyData: name = "BackendKeyData"
            case .bindComplete: name = "BindComplete"
            case .closeComplete: name = "CloseComplete"
            case .commandComplete: name = "CommandComplete"
            case .copyBothResponse: name = "CopyBothResponse"
            case .copyData: name = "CopyData"
            case .copyDone: name = "CopyDone"
            case .copyInResponse: name = "CopyInResponse"
            case .copyOutResponse: name = "CopyOutResponse"
            case .dataRow: name = "DataRow"
            case .emptyQueryResponse: name = "EmptyQueryResponse"
            case .errorResponse: name = "ErrorResponse"
            case .functionCallResponse: name = "FunctionCallResponse"
            case .negotiateProtocolVersion: name = "NegotiateProtocolVersion"
            case .noData: name = "NoData"
            case .noticeResponse: name = "NoticeResponse"
            case .notificationResponse: name = "NotificationResponse"
            case .parameterDescription: name = "ParameterDescription"
            case .parameterStatus: name = "ParameterStatus"
            case .parseComplete: name = "ParseComplete"
            case .portalSuspended: name = "PortalSuspended"
            case .readyForQuery: name = "ReadyForQuery"
            case .rowDescription: name = "RowDescription"
            case .sslSupported: name = "SSLSupported"
            case .sslUnsupported: name = "SSLUnsupported"
            default: name = "Unknown(\(backendIdentifier))"
            }
        }

        if identifier != .frontend(.sslRequest) && identifier != .frontend(.startupMessage) {
            return "\(name) (\(identifier))"
        }

        return name
    }
}
