import NIOCore
@testable import PostgreSQL
import XCTest

final class Int16Tests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(Int16.psqlFormat, .binary)
        XCTAssertEqual(Int16.psqlType, .int2)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .uuid
        let value: Int16 = 1
        var buffer = ByteBuffer()
        value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try Int16(buffer: &buffer, type: type)) { error in
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        for format in DataFormat.allCases {
            // Arrange
            let value: Int16 = 1
            var expectedValue: Int16?
            var buffer = ByteBuffer()
            value.encode(into: &buffer, with: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int16(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, value)
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValue = "text"
        let type: DataType = .int2

        for format in DataFormat.allCases {
            var buffer = ByteBuffer()
            invalidValue.encode(into: &buffer, with: format)

            // Act/Assert
            XCTAssertThrowsError(try Int16(buffer: &buffer, format: format, type: type)) { error in
                XCTAssertEqual(
                    error.localizedDescription,
                    PostgreSQL.error(.invalidData(format: format, type: type)).localizedDescription
                )
            }
        }
    }
}
