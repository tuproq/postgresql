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
        value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try Decimal(buffer: &buffer, type: type)) { error in
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let values: [Decimal] = [0, 1, -1, Decimal.pi, -Decimal.pi, 12345678.9, -12345678.9, 9999999999999, Decimal.greatestFiniteMagnitude]

        for value in values {
            let format: DataFormat = .binary
            var expectedValue: Decimal?
            var buffer = ByteBuffer()
            value.encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Decimal(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, value)
        }

        for value in values.map({ "\($0)" }) {
            let format: DataFormat = .text
            var expectedValue: Decimal?
            var buffer = ByteBuffer()
            value.encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Decimal(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, Decimal(string: value))
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValues: [Codable] = [true, "", "a"]
        let type: DataType = .numeric

        for format in DataFormat.allCases {
            for invalidValue in invalidValues {
                var buffer = ByteBuffer()
                invalidValue.encode(into: &buffer, format: format)

                // Act/Assert
                XCTAssertThrowsError(try Decimal(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertEqual(
                        error.localizedDescription,
                        PostgreSQL.error(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }
}
