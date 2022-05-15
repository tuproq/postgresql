@testable import PostgreSQL
import XCTest

final class MessageBindTests: BaseTests {
    let portalName = "portalName"
    let statementName = "statementName"
    let parameterDataFormats: [DataFormat] = [.text]
    var parameters: [ByteBuffer?]!
    let resultDataFormats: [DataFormat] = [.binary]

    override func setUp() {
        super.setUp()

        var parameter = ByteBuffer()
        parameter.writeInteger(1)
        parameters = [parameter]
    }

    func testInit() {
        // Act
        let messageType = Message.Bind(
            portalName: portalName,
            statementName: statementName,
            parameterDataFormats: parameterDataFormats,
            parameters: parameters,
            resultDataFormats: resultDataFormats
        )

        // Assert
        XCTAssertEqual(messageType.identifier, .bind)
        XCTAssertEqual(messageType.portalName, portalName)
        XCTAssertEqual(messageType.statementName, statementName)
        XCTAssertEqual(messageType.parameterDataFormats, parameterDataFormats)
        XCTAssertEqual(messageType.parameters, parameters)
        XCTAssertEqual(messageType.resultDataFormats, resultDataFormats)
    }

    func testEncode() {
        // Arrange
        var messageType = Message.Bind(
            portalName: portalName,
            statementName: statementName,
            parameterDataFormats: parameterDataFormats,
            parameters: [nil],
            resultDataFormats: resultDataFormats
        )
        var buffer = ByteBuffer()

        var expectedBuffer = ByteBuffer()
        expectedBuffer.writeNullTerminatedString(messageType.portalName)
        expectedBuffer.writeNullTerminatedString(messageType.statementName)
        expectedBuffer.writeArray(messageType.parameterDataFormats)
        expectedBuffer.writeArray(messageType.parameters) { expectedBuffer, _ in
            expectedBuffer.writeInteger(-1, as: Int32.self)
        }
        expectedBuffer.writeArray(messageType.resultDataFormats)

        // Act
        messageType.encode(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)

        // Arrange
        messageType = Message.Bind(
            portalName: portalName,
            statementName: statementName,
            parameterDataFormats: parameterDataFormats,
            parameters: parameters,
            resultDataFormats: resultDataFormats
        )
        buffer = ByteBuffer()

        expectedBuffer = ByteBuffer()
        expectedBuffer.writeNullTerminatedString(messageType.portalName)
        expectedBuffer.writeNullTerminatedString(messageType.statementName)
        expectedBuffer.writeArray(messageType.parameterDataFormats)
        expectedBuffer.writeArray(messageType.parameters) {
            if var value = $1 {
                $0.writeInteger(numericCast(value.readableBytes), as: Int32.self)
                $0.writeBuffer(&value)
            }
        }
        expectedBuffer.writeArray(messageType.resultDataFormats)

        // Act
        messageType.encode(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
