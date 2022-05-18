@testable import PostgreSQL
import XCTest

final class DoubleTests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(Double.psqlFormat, .binary)
        XCTAssertEqual(Double.psqlType, .float8)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .bool
        let value = 2.2
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try Double(buffer: &buffer, type: type)) { error in
            XCTAssertNotNil(error as? ClientError)
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let value: Float = 1.5
        var expectedValue: Double?
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer)

        // Act/Assert
        XCTAssertNoThrow(expectedValue = try Double(buffer: &buffer, type: .float4))
        XCTAssertEqual(expectedValue, Double(value))

        for format in DataFormat.allCases {
            // Arrange
            let value = 2.2
            var expectedValue: Double?
            var buffer = ByteBuffer()
            try? value.encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Double(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, value)
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValues: [DataType: Codable] = [
            .float4: true,
            .float8: "text"
        ]

        for format in DataFormat.allCases {
            for (type, invalidValue) in invalidValues {
                var buffer = ByteBuffer()
                try? invalidValue.encode(into: &buffer, format: format)

                // Act/Assert
                XCTAssertThrowsError(try Double(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertNotNil(error as? ClientError)
                    XCTAssertEqual(
                        error.localizedDescription,
                        PostgreSQL.error(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }
}
