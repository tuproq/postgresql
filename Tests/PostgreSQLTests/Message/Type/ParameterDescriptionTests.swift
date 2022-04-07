@testable import PostgreSQL
import XCTest

final class MessageParameterDescriptionTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Message.ParameterDescription(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse parameter data types.")
        }

        // Arrange
        let invalidDataType = -1
        buffer = ByteBuffer()
        buffer.writeArray([invalidDataType])

        // Act/Assert
        XCTAssertThrowsError(try Message.ParameterDescription(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse parameter data type.")
        }

        // Arrange
        let dataType: DataType = .int8
        buffer = ByteBuffer()
        buffer.writeArray([dataType.rawValue])

        // Act
        let messageType = try! Message.ParameterDescription(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .parameterDescription)
        XCTAssertEqual(messageType.dataTypes, [dataType])
    }
}
