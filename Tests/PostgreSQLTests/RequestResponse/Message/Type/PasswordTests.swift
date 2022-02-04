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
        XCTAssertEqual(messageType.identifier, .password)
        XCTAssertEqual(messageType.value, value)
    }

    func testWrite() {
        // Arrange
        let messageType = Message.Password("password")
        var buffer = ByteBufferAllocator().buffer(capacity: 0)

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer.getString(at: 0, length: buffer.readableBytes), "\(messageType.value)\0")
    }
}
