@testable import PostgreSQL
import XCTest

final class MessageTests: BaseTests {
    func testInit() {
        // Arrange
        let messageType = Message.StartupMessage(user: "user", database: "database")
        let source: Message.Source = .frontend
        var buffer = ByteBuffer()
        messageType.encode(into: &buffer)

        // Act
        let message = Message(identifier: messageType.identifier, source: source, buffer: buffer)

        // Assert
        XCTAssertEqual(message.identifier, messageType.identifier)
        XCTAssertEqual(message.source, source)
        XCTAssertEqual(message.buffer, buffer)
    }
}
