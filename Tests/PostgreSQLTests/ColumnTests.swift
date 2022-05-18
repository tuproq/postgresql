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
        XCTAssertThrowsError(column = try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? ClientError)
            XCTAssertEqual(error.localizedDescription, PostgreSQL.error(.invalidColumnName).localizedDescription)
        }

        // Arrange
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)

        // Act/Assert
        XCTAssertThrowsError(column = try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? ClientError)
            XCTAssertEqual(error.localizedDescription, PostgreSQL.error(.invalidColumnTableID).localizedDescription)
        }

        // Arrange
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)
        buffer.writeInteger(tableID)

        // Act/Assert
        XCTAssertThrowsError(column = try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? ClientError)
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidColumnAttributeNumber).localizedDescription
            )
        }

        // Arrange
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)
        buffer.writeInteger(tableID)
        buffer.writeInteger(attributeNumber)

        // Act/Assert
        XCTAssertThrowsError(column = try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? ClientError)
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidColumnDataTypeID).localizedDescription
            )
        }

        // Arrange
        buffer = ByteBuffer()
        buffer.writeNullTerminatedString(name)
        buffer.writeInteger(tableID)
        buffer.writeInteger(attributeNumber)
        buffer.writeInteger(dataTypeID.rawValue)

        // Act/Assert
        XCTAssertThrowsError(column = try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? ClientError)
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidColumnDataTypeSize).localizedDescription
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
        XCTAssertThrowsError(column = try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? ClientError)
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidColumnAttributeTypeModifier).localizedDescription
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
        XCTAssertThrowsError(column = try Column(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? ClientError)
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidColumnDataFormat).localizedDescription
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
