@testable import PostgreSQL
import XCTest

final class MessageSASLResponseTests: BaseTests {
    let data: [UInt8] = [1, 2]

    func testInit() {
        // Arrange
        var buffer = ByteBuffer()
        buffer.writeBytes(data)

        // Act
        let messageType = Message.SASLResponse(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .saslResponse)
        XCTAssertEqual(messageType.data, data)
    }

    func testWrite() {
        // Arrange
        let messageType = Message.SASLResponse(data: data)
        var buffer = ByteBuffer()

        var expectedBuffer = ByteBuffer()
        expectedBuffer.writeBytes(data)

        // Act
        messageType.encode(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
