@testable import PostgreSQL
import XCTest

final class UUIDTests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(UUID.psqlFormat, .binary)
        XCTAssertEqual(UUID.psqlType, .uuid)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .bool
        let value = UUID()
        var buffer = ByteBuffer()
        value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try UUID(buffer: &buffer, type: type)) { error in
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let value = UUID()
        var expectedValue: UUID?
        var buffer = ByteBuffer()
        value.encode(into: &buffer)

        // Act/Assert
        XCTAssertNoThrow(expectedValue = try UUID(buffer: &buffer))
        XCTAssertEqual(expectedValue, value)

        // Arrange
        let values: [DataType: String] = [
            .varchar: value.uuidString,
            .text: value.uuidString
        ]

        for format in DataFormat.allCases {
            for (type, value) in values {
                var expectedValue: UUID?
                var buffer = ByteBuffer()
                value.encode(into: &buffer, format: format)

                // Act/Assert
                XCTAssertNoThrow(expectedValue = try UUID(buffer: &buffer, format: format, type: type))
                XCTAssertEqual(expectedValue?.uuidString, value)
            }
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValues: [DataType: Codable] = [
            .uuid: "text",
            .varchar: UUID(),
            .text: UUID()
        ]

        for format in DataFormat.allCases {
            for (type, invalidValue) in invalidValues {
                var buffer = ByteBuffer()
                invalidValue.encode(into: &buffer, format: format)

                // Act/Assert
                XCTAssertThrowsError(try UUID(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertEqual(
                        error.localizedDescription,
                        PostgreSQL.error(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }
}
