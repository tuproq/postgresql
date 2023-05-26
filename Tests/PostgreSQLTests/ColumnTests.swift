@testable import PostgreSQL
import XCTest

final class ColumnTests: BaseTests {
    func testInit() {
        // Arrange
        let name = "id"
        let tableID: Int32 = 2
        let attributeNumber: Int16 = 1
        let dataTypeID: DataType = .uuid
        let dataTypeSize: Int16 = 16
        let attributeTypeModifier: Int32 = -1
        let dataFormat: DataFormat = .binary
        var column: Column?
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(error.localizedDescription, clientError(.invalidColumnName).localizedDescription)
        }

        // Arrange
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)

        // Act/Assert
        XCTAssertThrowsError(try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(error.localizedDescription, clientError(.invalidColumnTableID).localizedDescription)
        }

        // Arrange
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)
        buffer.writeInteger(tableID)

        // Act/Assert
        XCTAssertThrowsError(try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(.invalidColumnAttributeNumber).localizedDescription
            )
        }

        // Arrange
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)
        buffer.writeInteger(tableID)
        buffer.writeInteger(attributeNumber)

        // Act/Assert
        XCTAssertThrowsError(try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(.invalidColumnDataTypeID).localizedDescription
            )
        }

        // Arrange
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)
        buffer.writeInteger(tableID)
        buffer.writeInteger(attributeNumber)
        buffer.writeInteger(dataTypeID.rawValue)

        // Act/Assert
        XCTAssertThrowsError(try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(.invalidColumnDataTypeSize).localizedDescription
            )
        }

        // Arrange
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)
        buffer.writeInteger(tableID)
        buffer.writeInteger(attributeNumber)
        buffer.writeInteger(dataTypeID.rawValue)
        buffer.writeInteger(dataTypeSize)

        // Act/Assert
        XCTAssertThrowsError(try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(.invalidColumnAttributeTypeModifier).localizedDescription
            )
        }

        // Arrange
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)
        buffer.writeInteger(tableID)
        buffer.writeInteger(attributeNumber)
        buffer.writeInteger(dataTypeID.rawValue)
        buffer.writeInteger(dataTypeSize)
        buffer.writeInteger(attributeTypeModifier)

        // Act/Assert
        XCTAssertThrowsError(try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(.invalidColumnDataFormat).localizedDescription
            )
        }

        // Arrange
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)
        buffer.writeInteger(tableID)
        buffer.writeInteger(attributeNumber)
        buffer.writeInteger(dataTypeID.rawValue)
        buffer.writeInteger(dataTypeSize)
        buffer.writeInteger(attributeTypeModifier)
        buffer.writeInteger(dataFormat.rawValue)

        // Act/Assert
        XCTAssertNoThrow(column = try Column(buffer: &buffer))
        XCTAssertEqual(column?.name, name)
        XCTAssertEqual(column?.tableID, tableID)
        XCTAssertEqual(column?.attributeNumber, attributeNumber)
        XCTAssertEqual(column?.dataTypeID, dataTypeID)
        XCTAssertEqual(column?.dataTypeSize, dataTypeSize)
        XCTAssertEqual(column?.attributeTypeModifier, attributeTypeModifier)
        XCTAssertEqual(column?.dataFormat, dataFormat)
        XCTAssertEqual(column?.description, """
        name: \(name), \
        tableID: \(tableID), \
        attributeNumber: \(attributeNumber), \
        dataTypeID: \(dataTypeID), \
        dataTypeSize: \(dataTypeSize), \
        attributeTypeModifier: \(attributeTypeModifier), \
        dataFormat: \(dataFormat)
        """
        )
    }
}
