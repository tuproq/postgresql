@testable import PostgreSQL
import XCTest

final class FloatTests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(Float.psqlFormat, .binary)
        XCTAssertEqual(Float.psqlType, .float4)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .bool
        let value: Float = 1.5
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try Float(buffer: &buffer, type: type)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let value = 2.2
        var expectedValue: Float?
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer)

        // Act/Assert
        XCTAssertNoThrow(expectedValue = try Float(buffer: &buffer, type: .float8))
        XCTAssertEqual(expectedValue, Float(value))

        for format in DataFormat.allCases {
            // Arrange
            let value: Float = 1.5
            var expectedValue: Float?
            var buffer = ByteBuffer()
            try? value.encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Float(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, value)
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValues: [DataType: PostgreSQLCodable] = [
            .float4: true,
            .float8: "text"
        ]

        for format in DataFormat.allCases {
            for (type, invalidValue) in invalidValues {
                var buffer = ByteBuffer()
                try? invalidValue.encode(into: &buffer, format: format)

                // Act/Assert
                XCTAssertThrowsError(try Float(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertNotNil(error as? PostgreSQLError)
                    XCTAssertEqual(
                        error.localizedDescription,
                        clientError(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }
}
