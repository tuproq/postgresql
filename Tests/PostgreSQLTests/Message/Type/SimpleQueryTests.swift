@testable import PostgreSQL
import XCTest

final class MessageSimpleQueryTests: BaseTests {
    let query = "SELECT version()"

    func testInit() {
        // Act
        let messageType = Message.SimpleQuery(query)

        // Assert
        XCTAssertEqual(messageType.identifier, .simpleQuery)
        XCTAssertEqual(messageType.string, query)
    }

    func testWrite() {
        // Arrange
        let messageType = Message.SimpleQuery(query)
        var buffer = bufferAllocator.buffer(capacity: 0)

        var expectedBuffer = bufferAllocator.buffer(capacity: 0)
        expectedBuffer.writeNullTerminatedString(messageType.string)

        // Act
        messageType.encode(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
