import NIOCore
@testable import PostgreSQL
import XCTest

final class Int64Tests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(Int64.psqlFormat, .binary)
        XCTAssertEqual(Int64.psqlType, .int8)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .uuid
        let value: Int64 = 1
        var buffer = ByteBuffer()
        value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try Int64(buffer: &buffer, type: type)) { error in
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let formats = DataFormat.allCases
        var expectedValue: Int64?

        for format in formats {
            // Arrange
            let value: Int16 = 1
            let type: DataType = .int2
            var buffer = ByteBuffer()
            value.encode(into: &buffer, with: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int64(buffer: &buffer, format: format, type: type))
            XCTAssertEqual(expectedValue, Int64(value))
        }

        for format in formats {
            // Arrange
            let value: Int32 = 1
            let type: DataType = .int4
            var buffer = ByteBuffer()
            value.encode(into: &buffer, with: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int64(buffer: &buffer, format: format, type: type))
            XCTAssertEqual(expectedValue, Int64(value))
        }

        for format in formats {
            // Arrange
            let value: Int64 = 1
            var buffer = ByteBuffer()
            value.encode(into: &buffer, with: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int64(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, value)
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValue = UUID()
        let types: [DataType] = [.int2, .int4, .int8]

        for format in DataFormat.allCases {
            for type in types {
                var buffer = ByteBuffer()
                invalidValue.encode(into: &buffer, with: format)

                // Act/Assert
                XCTAssertThrowsError(try Int64(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertEqual(
                        error.localizedDescription,
                        PostgreSQL.error(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }
}
