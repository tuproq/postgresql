import NIOCore
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

    func testWrite() {
        // Arrange
        let messageType = Message.SSLRequest()
        var buffer = ByteBufferAllocator().buffer(capacity: 0)

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer.getInteger(at: 0), messageType.code)
    }
}
