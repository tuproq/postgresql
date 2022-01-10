@testable import PostgreSQL
import XCTest

final class MessageErrorTests: XCTestCase {
    func testInit() {
        // Arrange
        let message = "An unknown error."

        // Act
        let error = MessageError(message)

        // Assert
        XCTAssertEqual(error.errorDescription, message)
    }
}