import Foundation

public struct PostgreSQLError: LocalizedError {
    let message: String
    public var errorDescription: String? { message }

    init(_ errorType: ErrorType) {
        self.init(errorType.message)
    }

    init(_ errorType: ErrorType.Column) {
        self.init(errorType.rawValue)
    }

    init(_ errorType: ErrorType.Message) {
        self.init(errorType.message)
    }

    init(_ message: String? = nil) {
        let errorType = String(describing: type(of: self))

        if let message = message, !message.isEmpty {
            self.message = "\(errorType): \(message)"
        } else {
            self.message = "\(errorType): \(ErrorType.unknown)"
        }
    }
}

enum ErrorType: CustomStringConvertible {
    case decoding(type: String)
    case invalidData(format: DataFormat, type: DataType)
    case invalidDataType(_ type: DataType)
    case unknown

    var description: String { message }

    var message: String {
        switch self {
        case .decoding(let type): return "Can't decode the `\(type)`."
        case .invalidData(let format, let type):
            return "An invalid data type `\(type)` for data format `\(format)`."
        case .invalidDataType(let type): return "An invalid data type `\(type)`."
        case .unknown: return "An unknown error."
        }
    }
}

extension ErrorType {
    enum Column: String, CustomStringConvertible {
        case invalidColumnAttributeNumber = "An invalid column `attributeNumber`."
        case invalidColumnAttributeTypeModifier = "An invalid column `attributeTypeModifier`."
        case invalidColumnDataFormat = "An invalid column `dataFormat`."
        case invalidColumnDataTypeID = "An invalid column `dataTypeID`."
        case invalidColumnDataTypeSize = "An invalid column `dataTypeSize`."
        case invalidColumnName = "An invalid column `name`."
        case invalidColumnTableID = "An invalid column `tableID`."

        var description: String { rawValue }
    }
}

extension ErrorType {
    enum Message: CustomStringConvertible {
        case cantParseAuthenticationMethod
        case cantParseBackendKeyDataProcessID
        case cantParseBackendKeyDataSecretKey(processID: Int32)
        case cantParseCommandTag
        case cantParseDataRowValues
        case cantParseErrorResponseFields
        case cantParseNoticeResponseFields
        case cantParseNotificationChannel(processID: Int32)
        case cantParseNotificationPayload(processID: Int32, channel: String)
        case cantParseNotificationProcessID
        case cantParseParameterDataType
        case cantParseParameterDataTypes
        case cantParseParameterStatusName
        case cantParseParameterStatusValue(name: String)
        case cantParseReadyForQueryTransactionStatus
        case cantParseRowDescriptionColumns

        var description: String { message }

        var message: String {
            switch self {
            case .cantParseAuthenticationMethod: return "Can't parse Authentication method."
            case .cantParseBackendKeyDataProcessID: return "Can't parse BackendKeyData processID."
            case .cantParseBackendKeyDataSecretKey(let processID):
                return "Can't parse BackendKeyData secretKey for processID `\(processID)`."
            case .cantParseCommandTag: return "Can't parse CommandComplete tag."
            case .cantParseDataRowValues: return "Can't parse DataRow values."
            case .cantParseErrorResponseFields: return "Can't parse ErrorResponse fields."
            case .cantParseNoticeResponseFields: return "Can't parse NoticeResponse fields."
            case .cantParseNotificationChannel(let processID):
                return "Can't parse NotificationResponse channel for processID `\(processID)`."
            case .cantParseNotificationPayload(let processID, let channel):
                return """
                Can't parse NotificationResponse payload for processID `\(processID)` and channel `\(channel)`.
                """
            case .cantParseNotificationProcessID: return "Can't parse NotificationResponse processID."
            case .cantParseParameterDataType: return "Can't parse ParameterDescription type."
            case .cantParseParameterDataTypes: return "Can't parse ParameterDescription types."
            case .cantParseParameterStatusName: return "Can't parse ParameterStatus name."
            case .cantParseParameterStatusValue(let name):
                return "Can't parse ParameterStatus value for name `\(name)`."
            case .cantParseReadyForQueryTransactionStatus: return "Can't parse ReadyForQuery transactionStatus."
            case .cantParseRowDescriptionColumns: return "Can't parse RowDescription columns."
            }
        }
    }
}

func postgreSQLError(_ type: ErrorType) -> PostgreSQLError {
    PostgreSQLError(type)
}

func postgreSQLError(_ type: ErrorType.Column) -> PostgreSQLError {
    PostgreSQLError(type)
}

func postgreSQLError(_ type: ErrorType.Message) -> PostgreSQLError {
    PostgreSQLError(type)
}
