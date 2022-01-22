import NIOCore
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

    func testWrite() {
        // Arrange
        let messageType = Message.Query("SELECT version()")
        var buffer = ByteBufferAllocator().buffer(capacity: 0)

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer.getString(at: 0, length: buffer.readableBytes), "\(messageType.string)\0")
    }
}
