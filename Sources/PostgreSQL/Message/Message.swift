struct Message: CustomStringConvertible, Equatable {
    let identifier: Identifier
    let source: Source
    var buffer: ByteBuffer

    enum Source {
        case backend
        case frontend
    }

    var description: String {
        var name: String

        switch identifier {
        case .authentication: name = "Authentication"
        case .backendKeyData: name = "BackendKeyData"
        case .bind: name = "Bind"
        case .bindComplete: name = "BindComplete"
        case .close, .commandComplete:
            if source == .frontend {
                name = "Close"
            } else {
                name = "CommandComplete"
            }
        case .closeComplete: name = "CloseComplete"
        case .copyBothResponse: name = "CopyBothResponse"
        case .copyData: name = "CopyData"
        case .copyDone: name = "CopyDone"
        case .copyFail: name = "CopyFail"
        case .copyInResponse: name = "CopyInResponse"
        case .copyOutResponse, .flush:
            if source == .backend {
                name = "CopyOutResponse"
            } else {
                name = "Flush"
            }
        case .dataRow, .describe:
            if source == .backend {
                name = "DataRow"
            } else {
                name = "Describe"
            }
        case .emptyQueryResponse: name = "EmptyQueryResponse"
        case .errorResponse, .execute:
            if source == .backend {
                name = "ErrorResponse"
            } else {
                name = "Execute"
            }
        case .functionCall: name = "FunctionCall"
        case .functionCallResponse: name = "FunctionCallResponse"
        case .gssResponse, .password, .saslInitialResponse, .saslResponse:
            name = "GSSResponse/Password/SASLInitialResponse/SASLResponse"
        case .negotiateProtocolVersion: name = "NegotiateProtocolVersion"
        case .noData: name = "NoData"
        case .noticeResponse, .sslUnsupported: name = "NoticeResponse/SSLUnsupported"
        case .notificationResponse: name = "NotificationResponse"
        case .parameterDescription: name = "ParameterDescription"
        case .parameterStatus, .sslSupported, .sync:
            if source == .backend {
                name = "ParameterStatus/SSLSupported"
            } else {
                name = "Sync"
            }
        case .parse: name = "Parse"
        case .parseComplete: name = "ParseComplete"
        case .password: name = "Password"
        case .portalSuspended: name = "PortalSuspended"
        case .readyForQuery: name = "ReadyForQuery"
        case .rowDescription: name = "RowDescription"
        case .saslInitialResponse: name = "SASLInitialResponse"
        case .saslResponse: name = "SASLResponse"
        case .simpleQuery: name = "SimpleQuery"
        case .sslRequest, .startupMessage: name = "SSLRequest/StartupMessage"
        case .terminate: name = "Terminate"
        default: name = "Unknown"
        }

        if identifier != .sslRequest && identifier != .startupMessage {
            name += " (\(identifier))"
        }

        return name
    }
}
