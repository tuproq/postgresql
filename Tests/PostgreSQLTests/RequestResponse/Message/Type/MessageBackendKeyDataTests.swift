@testable import PostgreSQL
import XCTest

final class MessageBackendKeyDataTests: XCTestCase {
    func testInit() {
        // Arrange
        let processID: Int32 = 1
        let secretKey: Int32 = 2

        // Act
        let messageType = Message.BackendKeyData(processID: processID, secretKey: secretKey)

        // Assert
        XCTAssertEqual(messageType.identifier, .backendKeyData)
        XCTAssertEqual(messageType.processID, processID)
        XCTAssertEqual(messageType.secretKey, secretKey)
    }
}
