@testable import PostgreSQL
import XCTest

final class MessageParameterDescriptionTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = bufferAllocator.buffer(capacity: 0)

        // Act/Assert
        XCTAssertThrowsError(try Message.ParameterDescription(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse parameter data types.")
        }

        // Arrange
        let invalidDataType = -1
        buffer = bufferAllocator.buffer(capacity: 0)
        buffer.writeArray([invalidDataType])

        // Act/Assert
        XCTAssertThrowsError(try Message.ParameterDescription(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse parameter data type.")
        }

        // Arrange
        let dataType: Column.DataType = .int8
        buffer = bufferAllocator.buffer(capacity: 0)
        buffer.writeArray([dataType.rawValue])

        // Act
        let messageType = try! Message.ParameterDescription(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .parameterDescription)
        XCTAssertEqual(messageType.dataTypes, [dataType])
    }
}
