@testable import PostgreSQL
import XCTest

final class MessageParameterDescriptionTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Message.ParameterDescription(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? MessageError)
            XCTAssertEqual(error.localizedDescription, "Can't parse parameter data types.")
        }

        // Arrange
        let invalidDataTypeID = -1
        buffer = ByteBuffer()
        buffer.writeArray([invalidDataTypeID])

        // Act/Assert
        XCTAssertThrowsError(try Message.ParameterDescription(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? MessageError)
            XCTAssertEqual(error.localizedDescription, "Can't parse parameter data type.")
        }

        // Arrange
        let dataTypeID: DataType = .int8
        buffer = ByteBuffer()
        buffer.writeArray([dataTypeID.rawValue])

        // Act
        let messageType = try! Message.ParameterDescription(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .parameterDescription)
        XCTAssertEqual(messageType.dataTypeIDs, [dataTypeID])
    }
}
