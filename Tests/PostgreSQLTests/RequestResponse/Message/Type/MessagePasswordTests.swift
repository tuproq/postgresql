import NIOCore
@testable import PostgreSQL
import XCTest

final class MessagePasswordTests: XCTestCase {
    func testInit() {
        // Arrange
        let value = "password"

        // Act
        let messageType = Message.Password(value)

        // Assert
        XCTAssertEqual(messageType.value, value)
    }
}
