@testable import PostgreSQL
import XCTest

final class MessageParseTests: BaseTests {
    let statementName = "select"
    let query = "SELECT * FROM table WHERE id = $1"
    let parameterTypes: [DataType] = [.int8]

    func testInit() {
        // Act
        let messageType = Message.Parse(statementName: statementName, query: query, parameterTypes: parameterTypes)

        // Assert
        XCTAssertEqual(messageType.identifier, .parse)
        XCTAssertEqual(messageType.statementName, statementName)
        XCTAssertEqual(messageType.query, query)
        XCTAssertEqual(messageType.parameterTypes, parameterTypes)
    }

    func testEncode() {
        // Arrange
        let messageType = Message.Parse(statementName: statementName, query: query, parameterTypes: parameterTypes)
        var buffer = ByteBuffer()

        var expectedBuffer = ByteBuffer()
        expectedBuffer.writeNullTerminatedString(statementName)
        expectedBuffer.writeNullTerminatedString(query)
        expectedBuffer.writeInteger(numericCast(parameterTypes.count), as: Int16.self)
        for parameterType in parameterTypes { expectedBuffer.writeInteger(parameterType.rawValue) }

        // Act
        messageType.encode(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
