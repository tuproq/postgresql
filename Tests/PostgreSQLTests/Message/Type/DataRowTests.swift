@testable import PostgreSQL
import XCTest

final class MessageDataRowTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Message.DataRow(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(error.localizedDescription, clientError(.cantParseDataRowValues).localizedDescription)
        }

        // Arrange
        let values: [Bool] = [false, true]
        var messageType: Message.DataRow?
        buffer = ByteBuffer()
        buffer.writeArray(values) { buffer, value in
            try? value.encode(into: &buffer)
        }

        // Act/Assert
        XCTAssertNoThrow(messageType = try Message.DataRow(buffer: &buffer))
        XCTAssertEqual(messageType?.identifier, .dataRow)
        XCTAssertEqual(messageType?.values.count, 2)
    }
}
