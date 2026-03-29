@testable import PostgreSQL
import XCTest

final class MessageTests: BaseTests {
    func testInit() {
        // Arrange
        let messageType = Message.StartupMessage(user: "user", database: "database")
        let type: Message.Kind = .frontend
        var buffer = ByteBuffer()
        messageType.encode(into: &buffer)

        // Act
        let message = Message(
            identifier: messageType.identifier,
            type: type,
            buffer: buffer
        )

        // Assert
        XCTAssertEqual(message.identifier, messageType.identifier)
        XCTAssertEqual(message.type, type)
        XCTAssertEqual(message.buffer, buffer)
    }
}
