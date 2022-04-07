@testable import PostgreSQL
import XCTest

final class MessageSSLRequestTests: BaseTests {
    func testInit() {
        // Act
        let messageType = Message.SSLRequest()

        // Assert
        XCTAssertEqual(messageType.identifier, .none)
        XCTAssertEqual(messageType.code, 80877103)
    }

    func testWrite() {
        // Arrange
        let messageType = Message.SSLRequest()
        var buffer = bufferAllocator.buffer(capacity: 0)

        var expectedBuffer = bufferAllocator.buffer(capacity: 0)
        expectedBuffer.writeInteger(messageType.code)

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
