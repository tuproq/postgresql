@testable import PostgreSQL
import XCTest

final class MessageSyncTests: BaseTests {
    func testInit() {
        // Act
        let messageType = Message.Sync()

        // Assert
        XCTAssertEqual(messageType.identifier, .sync)
    }
}
