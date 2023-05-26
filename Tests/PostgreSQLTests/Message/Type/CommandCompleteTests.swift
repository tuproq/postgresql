@testable import PostgreSQL
import XCTest

final class MessageCommandCompleteTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Message.CommandComplete(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(error.localizedDescription, postgreSQLError(.cantParseCommandTag).localizedDescription)
        }

        // Arrange
        let command = "SELECT"
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(command)

        // Act
        let messageType = try! Message.CommandComplete(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .commandComplete)
        XCTAssertEqual(messageType.command, command)
    }
}
