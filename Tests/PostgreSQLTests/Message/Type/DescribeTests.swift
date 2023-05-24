@testable import PostgreSQL
import XCTest

final class MessageDescribeTests: BaseTests {
    let command: Message.Command = .portal
    let portalOrStatementName = "portalOrStatementName"

    func testInit() {
        // Act
        let messageType = Message.Describe(command: command, name: portalOrStatementName)

        // Assert
        XCTAssertEqual(messageType.identifier, .describe)
        XCTAssertEqual(messageType.command, command)
        XCTAssertEqual(messageType.name, portalOrStatementName)
    }

    func testCommands() {
        // Assert
        XCTAssertEqual(Message.Command.portal.rawValue, 0x50)
        XCTAssertEqual(Message.Command.statement.rawValue, 0x53)
    }

    func testEncode() {
        // Arrange
        let messageType = Message.Describe(command: command, name: portalOrStatementName)
        var buffer = ByteBuffer()

        var expectedBuffer = ByteBuffer()
        expectedBuffer.writeInteger(command.rawValue)
        expectedBuffer.writeNullTerminatedString(portalOrStatementName)

        // Act
        messageType.encode(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
