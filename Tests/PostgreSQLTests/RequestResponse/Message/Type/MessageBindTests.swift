import NIOCore
@testable import PostgreSQL
import XCTest

final class MessageBindTests: XCTestCase {
    let portalName = "portalName"
    let statementName = "statementName"
    let parameterFormatCodes: [Column.FormatCode] = [.text]
    var parameters: [ByteBuffer?]!
    let resultFormatCodes: [Column.FormatCode] = [.binary]

    override func setUp() {
        super.setUp()

        var parameter = ByteBufferAllocator().buffer(capacity: 0)
        parameter.writeInteger(1)
        parameters = [parameter]
    }

    func testInit() {
        // Act
        let messageType = Message.Bind(
            portalName: portalName,
            statementName: statementName,
            parameterFormatCodes: parameterFormatCodes,
            parameters: parameters,
            resultFormatCodes: resultFormatCodes
        )

        // Assert
        XCTAssertEqual(messageType.identifier, .bind)
        XCTAssertEqual(messageType.portalName, portalName)
        XCTAssertEqual(messageType.statementName, statementName)
        XCTAssertEqual(messageType.parameterFormatCodes, parameterFormatCodes)
        XCTAssertEqual(messageType.parameters, parameters)
        XCTAssertEqual(messageType.resultFormatCodes, resultFormatCodes)
    }

    func testWrite() {
        // Arrange
        var messageType = Message.Bind(
            portalName: portalName,
            statementName: statementName,
            parameterFormatCodes: parameterFormatCodes,
            parameters: [nil],
            resultFormatCodes: resultFormatCodes
        )
        var buffer = ByteBufferAllocator().buffer(capacity: 0)

        var expectedBuffer = ByteBufferAllocator().buffer(capacity: 0)
        expectedBuffer.writeNullTerminatedString(messageType.portalName)
        expectedBuffer.writeNullTerminatedString(messageType.statementName)
        expectedBuffer.writeArray(messageType.parameterFormatCodes)
        expectedBuffer.writeArray(messageType.parameters) { expectedBuffer, _ in
            expectedBuffer.writeInteger(-1, as: Int32.self)
        }
        expectedBuffer.writeArray(messageType.resultFormatCodes)

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)

        // Arrange
        messageType = Message.Bind(
            portalName: portalName,
            statementName: statementName,
            parameterFormatCodes: parameterFormatCodes,
            parameters: parameters,
            resultFormatCodes: resultFormatCodes
        )
        buffer = ByteBufferAllocator().buffer(capacity: 0)

        expectedBuffer = ByteBufferAllocator().buffer(capacity: 0)
        expectedBuffer.writeNullTerminatedString(messageType.portalName)
        expectedBuffer.writeNullTerminatedString(messageType.statementName)
        expectedBuffer.writeArray(messageType.parameterFormatCodes)
        expectedBuffer.writeArray(messageType.parameters) {
            if var value = $1 {
                $0.writeInteger(numericCast(value.readableBytes), as: Int32.self)
                $0.writeBuffer(&value)
            }
        }
        expectedBuffer.writeArray(messageType.resultFormatCodes)

        // Act
        messageType.write(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }
}
