@testable import PostgreSQL
import XCTest

final class DecimalTests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(Decimal.psqlFormat, .binary)
        XCTAssertEqual(Decimal.psqlType, .numeric)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .bool
        let value: Decimal = .pi
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try Decimal(buffer: &buffer, type: type)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let values: [Decimal] = [
            0,
            1,
            -1,
            Decimal.pi,
            -Decimal.pi,
            12345678.9,
            -12345678.9,
            9999999999999,
            Decimal.greatestFiniteMagnitude
        ]

        for value in values {
            let format: DataFormat = .binary
            var expectedValue: Decimal?
            var buffer = ByteBuffer()
            try? value.encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Decimal(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, value)
        }

        for value in values.map({ "\($0)" }) {
            let format: DataFormat = .text
            var expectedValue: Decimal?
            var buffer = ByteBuffer()
            try? value.encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Decimal(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, Decimal(string: value))
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValues: [PostgreSQLCodable] = [true, "", "a"]
        let type: DataType = .numeric

        for format in DataFormat.allCases {
            for invalidValue in invalidValues {
                var buffer = ByteBuffer()
                try? invalidValue.encode(into: &buffer, format: format)

                // Act/Assert
                XCTAssertThrowsError(try Decimal(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertNotNil(error as? PostgreSQLError)
                    XCTAssertEqual(
                        error.localizedDescription,
                        postgreSQLError(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }

    // MARK: Text-format round-trips (fix #42)

    func testTextFormatRoundTrip() {
        // Arrange — values that must survive encode→decode in text format
        let values: [Decimal] = [
            0,
            1,
            -1,
            Decimal(string: "3.14")!,
            Decimal(string: "-2.71828")!,
            Decimal(string: "123456789.987654321")!,
            Decimal(string: "-0.001")!,
            Decimal(string: "99999999999999999999")!
        ]

        for value in values {
            var buffer = ByteBuffer()
            // Should not throw
            XCTAssertNoThrow(try value.encode(into: &buffer, format: .text, type: .numeric))

            var decoded: Decimal?
            XCTAssertNoThrow(decoded = try Decimal(buffer: &buffer, format: .text, type: .numeric))
            XCTAssertEqual(decoded, value, "Round-trip failed for \(value)")
        }
    }

    func testTextFormatEncodeIsLocaleIndependent() {
        // Arrange — encode a value that would be locale-sensitive if the decimal
        // separator depended on the current locale.
        let value = Decimal(string: "3.14")!
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer, format: .text, type: .numeric)

        // Act — read raw bytes from buffer
        let encoded = buffer.readString() ?? ""

        // Assert — the wire representation must always use '.' as decimal separator
        // regardless of the process locale.
        XCTAssertTrue(
            encoded.contains("."),
            "Expected '.' as decimal separator, got: \(encoded)"
        )
        XCTAssertFalse(
            encoded.contains(","),
            "Locale-sensitive encoding with comma detected: \(encoded)"
        )
    }

    func testTextFormatNegativeValue() {
        // Arrange
        let value = Decimal(string: "-99.99")!
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer, format: .text, type: .numeric)
        let encoded = buffer.readString() ?? ""

        // Assert — negative sign must be preserved
        XCTAssertTrue(encoded.hasPrefix("-"), "Expected leading '-' for negative value, got: \(encoded)")
    }

    func testTextFormatZero() {
        // Arrange
        let value: Decimal = 0
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer, format: .text, type: .numeric)

        var decoded: Decimal?
        XCTAssertNoThrow(decoded = try Decimal(buffer: &buffer, format: .text, type: .numeric))
        XCTAssertEqual(decoded, 0)
    }
}
