import NIOCore
@testable import PostgreSQL
import XCTest

final class MessageRowDescriptionTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = bufferAllocator.buffer(capacity: 0)

        // Act/Assert
        XCTAssertThrowsError(try Message.RowDescription(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse row description columns.")
        }

        // Arrange
        var columnBuffer = bufferAllocator.buffer(capacity: 0)
        columnBuffer.writeNullTerminatedString("id")
        columnBuffer.writeInteger(Int32(1))
        columnBuffer.writeInteger(Int16(2))
        columnBuffer.writeInteger(Column.DataType.uuid.rawValue)
        columnBuffer.writeInteger(Int16(16))
        columnBuffer.writeInteger(Int32(3))
        columnBuffer.writeInteger(Column.FormatCode.text.rawValue)

        let columns: [Column] = [try! Column(buffer: &columnBuffer)]

        buffer = bufferAllocator.buffer(capacity: 0)
        buffer.writeArray(columns) { columnBuffer, column in
            columnBuffer.writeNullTerminatedString(column.name)
            columnBuffer.writeInteger(column.tableID)
            columnBuffer.writeInteger(column.attributeNumber)
            columnBuffer.writeInteger(column.dataType.rawValue)
            columnBuffer.writeInteger(column.dataTypeSize)
            columnBuffer.writeInteger(column.attributeTypeModifier)
            columnBuffer.writeInteger(column.formatCode.rawValue)
        }

        // Act
        let messageType = try! Message.RowDescription(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .rowDescription)
        XCTAssertEqual(messageType.columns, columns)
    }
}
