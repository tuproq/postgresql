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

    init(_ message: String? = nil) {
        let errorType = String(describing: type(of: self))

        if let message = message, !message.isEmpty {
            self.message = "\(errorType): \(message)"
        } else {
            self.message = "\(errorType): \(ErrorType.unknown)"
        }
    }
}

struct MessageError: LocalizedError {
    private let message: String?
    var errorDescription: String? { message }

    init(_ message: String? = nil) {
        self.message = message
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

func error(_ errorType: ErrorType) -> PostgreSQLError {
    PostgreSQLError(errorType)
}

func error(_ errorType: ErrorType.Column) -> PostgreSQLError {
    PostgreSQLError(errorType)
}
