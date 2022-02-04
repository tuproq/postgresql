@testable import PostgreSQL
import XCTest

final class MessageSyncTests: XCTestCase {
    func testInit() {
        // Act
        let messageType = Message.Sync()

        // Assert
        XCTAssertEqual(messageType.identifier, .sync)
    }
}
