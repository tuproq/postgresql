@testable import PostgreSQL
import XCTest

final class MessageStartupTests: XCTestCase {
    func testInit() {
        // Arrange
        let user = "user"

        // Act
        let messageType = Message.Startup(user: user)

        // Assert
        XCTAssertEqual(messageType.identifier, .startup)
        XCTAssertEqual(messageType.protocolVersion, 0x00_03_00_00)
        XCTAssertEqual(messageType.user, user)
        XCTAssertEqual (messageType.database, user)
        XCTAssertEqual(messageType.replication, .false)
    }
}
