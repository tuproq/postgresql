@testable import PostgreSQL
import XCTest

final class ResultTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = ByteBuffer()
        buffer.writeNullTerminatedString("id")
        buffer.writeInteger(Int32(2))
        buffer.writeInteger(Int16(1))
        buffer.writeInteger(DataType.uuid.rawValue)
        buffer.writeInteger(Int16(16))
        buffer.writeInteger(Int32(-1))
        buffer.writeInteger(DataFormat.binary.rawValue)

        let columns = [try! Column(buffer: &buffer)]
        let data = [[columns.first!.name: UUID()]]

        // Act
        let result = Result(columns: columns)
        result.data = data

        // Assert
        XCTAssertEqual(result.columns, columns)
        XCTAssertEqual(result.data as? [[String: UUID]], data)
    }
}
