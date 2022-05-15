@testable import PostgreSQL
import XCTest

final class MessageExecuteTests: BaseTests {
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

    func testEncode() {
        // Arrange
        let messageType = Message.Execute(portalName: portalName, maxRows: maxRows)
        var buffer = ByteBuffer()

        var expectedBuffer = ByteBuffer()
        expectedBuffer.writeNullTerminatedString(portalName)
        expectedBuffer.writeInteger(maxRows)

        // Act
        messageType.encode(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
