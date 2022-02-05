import NIOCore
@testable import PostgreSQL
import XCTest

final class MessageStartupMessageTests: XCTestCase {
    func testInit() {
        // Arrange
        let user = "user"

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
        let messageType = Message.StartupMessage(user: "user")
        var buffer = ByteBufferAllocator().buffer(capacity: 0)

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer.getString(at: 0, length: buffer.readableBytes), """
        \0\u{03}\0\0\
        user\0\(messageType.user)\0\
        database\0\(messageType.database)\0\
        replication\0\(messageType.replication.rawValue)\0\
        \0
        """
        )
    }
}
