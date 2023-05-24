@testable import PostgreSQL
import XCTest

final class MessageSSLRequestTests: BaseTests {
    func testInit() {
        // Act
        let messageType = Message.SSLRequest()

        // Assert
        XCTAssertEqual(messageType.identifier, .sslRequest)
        XCTAssertEqual(messageType.code, 80877103)
    }

    func testEncode() {
        // Arrange
        let messageType = Message.SSLRequest()
        var buffer = ByteBuffer()

        var expectedBuffer = ByteBuffer()
        expectedBuffer.writeInteger(messageType.code)

        // Act
        messageType.encode(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
