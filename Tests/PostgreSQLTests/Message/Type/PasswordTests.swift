@testable import PostgreSQL
import XCTest

final class MessagePasswordTests: BaseTests {
    let password = "password"

    func testInit() {
        // Act
        let messageType = Message.Password(password)

        // Assert
        XCTAssertEqual(messageType.identifier, .password)
        XCTAssertEqual(messageType.value, password)
    }

    func testWrite() {
        // Arrange
        let messageType = Message.Password(password)
        var buffer = bufferAllocator.buffer(capacity: 0)

        var expectedBuffer = bufferAllocator.buffer(capacity: 0)
        expectedBuffer.writeNullTerminatedString(messageType.value)

        // Act
        messageType.encode(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
