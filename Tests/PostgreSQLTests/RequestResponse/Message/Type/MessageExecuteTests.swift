import NIOCore
@testable import PostgreSQL
import XCTest

final class MessageExecuteTests: XCTestCase {
    let portalName = "insert"
    let maxRows: Int32 = 10

    func testInit() {
        // Act
        let messageType = Message.Execute(portalName: portalName, maxRows: maxRows)

        // Assert
        XCTAssertEqual(messageType.identifier, .execute)
        XCTAssertEqual(messageType.portalName, portalName)
        XCTAssertEqual(messageType.maxRows, maxRows)
    }

    func testWrite() {
        // Arrange
        let messageType = Message.Execute(portalName: portalName, maxRows: maxRows)
        var buffer = ByteBufferAllocator().buffer(capacity: 0)

        var expectedBuffer = ByteBufferAllocator().buffer(capacity: 0)
        expectedBuffer.writeNullTerminatedString(portalName)
        expectedBuffer.writeInteger(maxRows)

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
