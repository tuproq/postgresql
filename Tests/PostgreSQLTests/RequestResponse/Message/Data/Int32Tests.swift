import NIOCore
@testable import PostgreSQL
import XCTest

final class Int32Tests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(Int32.psqlFormat, .binary)
        XCTAssertEqual(Int32.psqlType, .int4)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .uuid
        let value: Int32 = 1
        var buffer = ByteBuffer()
        value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try Int32(buffer: &buffer, type: type)) { error in
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let formats = DataFormat.allCases
        var expectedValue: Int32?

        for format in formats {
            // Arrange
            let value: Int16 = 1
            let type: DataType = .int2
            var buffer = ByteBuffer()
            value.encode(into: &buffer, with: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int32(buffer: &buffer, format: format, type: type))
            XCTAssertEqual(expectedValue, Int32(value))
        }

        for format in formats {
            // Arrange
            let value: Int32 = 1
            var buffer = ByteBuffer()
            value.encode(into: &buffer, with: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int32(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, value)
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValue = UUID()
        let types: [DataType] = [.int2, .int4]

        for format in DataFormat.allCases {
            for type in types {
                var buffer = ByteBuffer()
                invalidValue.encode(into: &buffer, with: format)

                // Act/Assert
                XCTAssertThrowsError(try Int32(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertEqual(
                        error.localizedDescription,
                        PostgreSQL.error(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }
}
