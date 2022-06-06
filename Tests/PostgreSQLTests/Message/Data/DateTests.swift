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

        for format in DataFormat.allCases {
            var buffer = ByteBuffer()
            try? value.encode(into: &buffer, format: format, type: type)

            // Act/Assert
            XCTAssertThrowsError(try Date(buffer: &buffer, format: format, type: type)) { error in
                XCTAssertNotNil(error as? ClientError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidDataType(type)).localizedDescription
                )
            }
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let calendar = Calendar.current
        let value = Date()
        let type: DataType = .date
        var expectedValue: Date?
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer)

        // Act/Assert
        XCTAssertNoThrow(expectedValue = try Date(buffer: &buffer))
        XCTAssertEqual(expectedValue, value)

        // Arrange
        for format in DataFormat.allCases {
            var expectedValue: Date?
            var buffer = ByteBuffer()
            try? value.encode(into: &buffer, format: format, type: type)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Date(buffer: &buffer, format: format, type: type))
            XCTAssertEqual(
                calendar.dateComponents([.day, .month, .year], from: expectedValue!),
                calendar.dateComponents([.day, .month, .year], from: value)
            )
        }

        // Arrange
        let values: [DataType: Date] = [
            .timestamp: value,
            .timestamptz: value
        ]

        for format in DataFormat.allCases {
            for (type, value) in values {
                var expectedValue: Date?
                var buffer = ByteBuffer()
                try? value.encode(into: &buffer, format: format, type: type)

                // Act/Assert
                XCTAssertNoThrow(expectedValue = try Date(buffer: &buffer, format: format, type: type))
                XCTAssertEqual(
                    calendar.dateComponents([.second, .minute, .hour, .day, .month, .year], from: expectedValue!),
                    calendar.dateComponents([.second, .minute, .hour, .day, .month, .year], from: value)
                )
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
                try? invalidValue.encode(into: &buffer, format: format)

                // Act/Assert
                XCTAssertThrowsError(try Date(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertNotNil(error as? ClientError)
                    XCTAssertEqual(
                        error.localizedDescription,
                        clientError(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }
}
