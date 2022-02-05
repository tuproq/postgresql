import NIOCore
@testable import PostgreSQL
import XCTest

final class MessageTests: XCTestCase {
    func testInit() {
        // Arrange
        let messageType = Message.StartupMessage(user: "user", database: "database")
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        messageType.write(into: &buffer)

        // Act
        let message = Message(identifier: messageType.identifier, buffer: buffer)

        // Assert
        XCTAssertEqual(message.identifier, messageType.identifier)
        XCTAssertEqual(message.buffer, buffer)
    }
}
