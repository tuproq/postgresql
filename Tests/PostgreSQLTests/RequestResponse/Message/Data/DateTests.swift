import NIOCore
@testable import PostgreSQL
import XCTest

final class DateTests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(Date.psqlFormat, .binary)
        XCTAssertEqual(Date.psqlType, .timestamptz)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .bool
        let value = Date()
        var buffer = ByteBuffer()
        value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try Date(buffer: &buffer, type: type)) { error in
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let calendar = Calendar.current
        let value = Date()
        let type: DataType = .date
        var expectedValue: Date?
        var buffer = ByteBuffer()
        value.encode(into: &buffer)

        // Act/Assert
        XCTAssertNoThrow(expectedValue = try Date(buffer: &buffer))
        XCTAssertEqual(expectedValue, value)

        // Arrange
        buffer = ByteBuffer()
        value.encode(into: &buffer, type: type)

        // Act/Assert
        XCTAssertNoThrow(expectedValue = try Date(buffer: &buffer, type: type))
        XCTAssertEqual(
            calendar.dateComponents([.day, .month, .year], from: expectedValue!),
            calendar.dateComponents([.day, .month, .year], from: value)
        )

        // Arrange
        let values: [DataType: Date] = [
            .timestamp: value,
            .timestamptz: value
        ]

        for format in DataFormat.allCases {
            for (type, value) in values {
                var expectedValue: Date?
                var buffer = ByteBuffer()
                value.encode(into: &buffer, type: type)

                // Act/Assert
                XCTAssertNoThrow(expectedValue = try Date(buffer: &buffer, format: format, type: type))
                XCTAssertEqual(expectedValue, value)
            }
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValues: [DataType: Codable] = [
            .date: 1,
            .timestamp: UUID(),
            .timestamptz: true
        ]

        for format in DataFormat.allCases {
            for (type, invalidValue) in invalidValues {
                var buffer = ByteBuffer()
                invalidValue.encode(into: &buffer, format: format)

                // Act/Assert
                XCTAssertThrowsError(try Date(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertEqual(
                        error.localizedDescription,
                        PostgreSQL.error(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }
}