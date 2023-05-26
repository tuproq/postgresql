@testable import PostgreSQL
import XCTest

final class MessageParameterStatusTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Message.ParameterStatus(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.cantParseParameterStatusName).localizedDescription
            )
        }

        // Arrange
        let name = "client_encoding"
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)

        // Act/Assert
        XCTAssertThrowsError(try Message.ParameterStatus(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.cantParseParameterStatusValue(name: name)).localizedDescription
            )
        }

        // Arrange
        let value = "UTF8"
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)
        buffer.writeNullTerminatedString(value)

        // Act
        let messageType = try! Message.ParameterStatus(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .parameterStatus)
        XCTAssertEqual(messageType.name, name)
        XCTAssertEqual(messageType.value, value)
    }
}
