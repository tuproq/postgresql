import Foundation

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
            return "An invalid data for data format `\(format)` and data type `\(type)`."
        case .invalidDataType(let type): return "An invalid data type `\(type)`."
        case .unknown: return "An unknown error."
        }
    }
}
