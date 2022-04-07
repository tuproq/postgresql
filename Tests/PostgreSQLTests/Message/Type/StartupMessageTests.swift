@testable import PostgreSQL
import XCTest

final class MessageStartupMessageTests: BaseTests {
    let user = "user"

    func testInit() {
        // Act
        let messageType = Message.StartupMessage(user: user)

        // Assert
        XCTAssertEqual(messageType.identifier, .none)
        XCTAssertEqual(messageType.protocolVersion, 0x00_03_00_00)
        XCTAssertEqual(messageType.user, user)
        XCTAssertEqual (messageType.database, user)
        XCTAssertEqual(messageType.replication, .false)
    }

    func testWrite() {
        // Arrange
        let messageType = Message.StartupMessage(user: user)
        var buffer = bufferAllocator.buffer(capacity: 0)

        var expectedBuffer = bufferAllocator.buffer(capacity: 0)
        expectedBuffer.writeInteger(messageType.protocolVersion)
        expectedBuffer.writeNullTerminatedString("user")
        expectedBuffer.writeNullTerminatedString(messageType.user)
        expectedBuffer.writeNullTerminatedString("database")
        expectedBuffer.writeNullTerminatedString(messageType.database)
        expectedBuffer.writeNullTerminatedString("replication")
        expectedBuffer.writeNullTerminatedString(messageType.replication.rawValue)
        expectedBuffer.writeNullTerminatedString("")

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
