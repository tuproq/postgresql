import NIOCore
@testable import PostgreSQL
import XCTest

final class MessageSASLResponseTests: XCTestCase {
    let data: [UInt8] = [1, 2]

    func testInit() {
        // Arrange
        let bufferAllocator = ByteBufferAllocator()
        var buffer = bufferAllocator.buffer(capacity: 0)
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
        var buffer = ByteBufferAllocator().buffer(capacity: 0)

        var expectedBuffer = ByteBufferAllocator().buffer(capacity: 0)
        expectedBuffer.writeBytes(data)

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
