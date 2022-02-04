import NIOCore
@testable import PostgreSQL
import XCTest

final class MessageCloseTests: XCTestCase {
    let command: Message.Close.Command = .portal
    let portalOrStatementName = "portalOrStatementName"

    func testInit() {
        // Act
        let messageType = Message.Close(command: command, name: portalOrStatementName)

        // Assert
        XCTAssertEqual(messageType.identifier, .close)
        XCTAssertEqual(messageType.command, command)
        XCTAssertEqual(messageType.name, portalOrStatementName)
    }

    func testCommands() {
        // Assert
        XCTAssertEqual(Message.Close.Command.portal.rawValue, 0x50)
        XCTAssertEqual(Message.Close.Command.statement.rawValue, 0x53)
    }

    func testWrite() {
        // Arrange
        let messageType = Message.Close(command: command, name: portalOrStatementName)
        var buffer = ByteBufferAllocator().buffer(capacity: 0)

        var expectedBuffer = ByteBufferAllocator().buffer(capacity: 0)
        expectedBuffer.writeInteger(command.rawValue)
        expectedBuffer.writeNullTerminatedString(portalOrStatementName)

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}

