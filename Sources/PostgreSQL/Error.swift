import Foundation

public struct ClientError: LocalizedError {
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
    case invalidData(format: DataFormat, type: DataType)
    case invalidDataType(_ type: DataType)
    case unknown

    var description: String { message }

    var message: String {
        switch self {
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
        case cantParseBackendKeyDataProcessID
        case cantParseBackendKeyDataSecretKey(processID: Int32)
        case cantParseCommandTag
        case cantParseDataRowValues
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
            case .cantParseBackendKeyDataProcessID: return "Can't parse BackendKeyData processID."
            case .cantParseBackendKeyDataSecretKey(let processID):
                return "Can't parse BackendKeyData secretKey for processID `\(processID)`."
            case .cantParseCommandTag: return "Can't parse CommandComplete tag."
            case .cantParseDataRowValues: return "Can't parse DataRow values."
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

func clientError(_ type: ErrorType) -> ClientError {
    ClientError(type)
}

func clientError(_ type: ErrorType.Column) -> ClientError {
    ClientError(type)
}

func clientError(_ type: ErrorType.Message) -> ClientError {
    ClientError(type)
}
