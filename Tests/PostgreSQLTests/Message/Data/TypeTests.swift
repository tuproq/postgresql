@testable import PostgreSQL
import XCTest

final class TypeTests: BaseTests {
    func testEncodeWithInvalidType() {
        // Arrange
        let values: [DataType: Codable] = [
            .bool: "text",
            .bpchar: true,
            .bytea: Int16(1),
            .char: Int32(1),
            .date: Int64(1),
            .int2: Float(1),
            .int4: Double(1),
            .int8: Decimal(1),
            .name: 1,
            .float4: Data("text".utf8),
            .float8: UUID(),
            .uuid: UInt8(1)
        ]
        var buffer = ByteBuffer()

        for (dateType, value) in values {
            // Act/Assert
            XCTAssertThrowsError(try value.encode(into: &buffer, type: dateType)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    PostgreSQL.error(.invalidDataType(dateType)).localizedDescription
                )
            }
        }
    }
}
