@testable import PostgreSQL
import XCTest

final class UInt8Tests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(UInt8.psqlFormat, .binary)
        XCTAssertEqual(UInt8.psqlType, .char)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .uuid
        let value: UInt8 = 1
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try UInt8(buffer: &buffer, type: type)) { error in
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let values: [UInt8] = [UInt8(ascii: "a"), 1]

        for format in DataFormat.allCases {
            for value in values {
                var expectedValue: UInt8?
                var buffer = ByteBuffer()
                try? value.encode(into: &buffer, format: format)

                // Act/Assert
                XCTAssertNoThrow(expectedValue = try UInt8(buffer: &buffer, format: format))
                XCTAssertEqual(expectedValue, value)
            }
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValues: [DataType: Codable] = [
            .bpchar: UUID(),
            .char: "text"
        ]

        for format in DataFormat.allCases {
            for (type, invalidValue) in invalidValues {
                var buffer = ByteBuffer()
                try? invalidValue.encode(into: &buffer, format: format)

                // Act/Assert
                XCTAssertThrowsError(try UInt8(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertEqual(
                        error.localizedDescription,
                        PostgreSQL.error(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }
}
