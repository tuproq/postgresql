@testable import PostgreSQL
import XCTest

final class MessageSSLRequestTests: XCTestCase {
    func testInit() {
        // Act
        let messageType = Message.SSLRequest()

        // Assert
        XCTAssertEqual(messageType.identifier, .sslRequest)
        XCTAssertEqual(messageType.code, 80877103)
    }
}
