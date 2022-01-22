@testable import PostgreSQL
import XCTest

final class MessageQueryTests: XCTestCase {
    func testInit() {
        // Arrange
        let string = "SELECT version()"

        // Act
        let messageType = Message.Query(string)

        // Assert
        XCTAssertEqual(messageType.identifier, .query)
        XCTAssertEqual(messageType.string, string)
    }
}
