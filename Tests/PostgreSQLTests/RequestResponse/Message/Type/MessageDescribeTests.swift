import NIOCore
@testable import PostgreSQL
import XCTest

final class MessageDescribeTests: XCTestCase {
    let command: Message.Describe.Command = .portal
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
        XCTAssertEqual(Message.Describe.Command.portal.rawValue, 0x50)
        XCTAssertEqual(Message.Describe.Command.statement.rawValue, 0x53)
    }

    func testWrite() {
        // Arrange
        let messageType = Message.Describe(command: command, name: portalOrStatementName)
        var buffer = ByteBufferAllocator().buffer(capacity: 0)

        var resultBuffer = ByteBufferAllocator().buffer(capacity: 0)
        resultBuffer.writeInteger(command.rawValue)
        resultBuffer.writeNullTerminatedString(portalOrStatementName)

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, resultBuffer)
    }
}
