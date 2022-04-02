import Foundation

struct MessageError: LocalizedError {
    private let message: String?
    var errorDescription: String? { message }

    init(_ message: String? = nil) {
        self.message = message
    }
}
