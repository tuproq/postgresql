@testable import PostgreSQL
import XCTest

final class MessageTerminateTests: XCTestCase {
    func testInit() {
        // Act
        let messageType = Message.Terminate()

        // Assert
        XCTAssertEqual(messageType.identifier, .terminate)
    }
}
