@testable import PostgreSQL
import XCTest

final class DataTests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(Data.psqlFormat, .binary)
        XCTAssertEqual(Data.psqlType, .bytea)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .bool
        let value = Data("text".utf8)

        for format in DataFormat.allCases {
            var buffer = ByteBuffer()
            try? value.encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertThrowsError(try Data(buffer: &buffer, format: format, type: type)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidDataType(type)).localizedDescription
                )
            }
        }
    }

    // MARK: Binary format

    func testInitWithBinaryFormat() {
        // Arrange
        let format: DataFormat = .binary
        let value = Data("text".utf8)
        var expectedValue: Data?
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer, format: format)

        // Act/Assert
        XCTAssertNoThrow(expectedValue = try Data(buffer: &buffer, format: format))
        XCTAssertEqual(expectedValue, value)
    }

    func testInitWithBinaryFormatEmptyData() {
        // Arrange
        let format: DataFormat = .binary
        let value = Data()
        var expectedValue: Data?
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer, format: format)

        // Act/Assert
        XCTAssertNoThrow(expectedValue = try Data(buffer: &buffer, format: format))
        XCTAssertEqual(expectedValue, value)
    }

    func testInitWithBinaryFormatArbitraryBytes() {
        // Arrange
        let format: DataFormat = .binary
        let value = Data([0x00, 0xFF, 0xDE, 0xAD, 0xBE, 0xEF])
        var expectedValue: Data?
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer, format: format)

        // Act/Assert
        XCTAssertNoThrow(expectedValue = try Data(buffer: &buffer, format: format))
        XCTAssertEqual(expectedValue, value)
    }

    // MARK: Text format

    func testInitWithTextFormat() {
        // Arrange — encode + decode round-trip
        let format: DataFormat = .text
        let values: [Data] = [
            Data("hello".utf8),
            Data([0xDE, 0xAD, 0xBE, 0xEF]),
            Data([0x00, 0xFF]),
            Data()
        ]

        for value in values {
            var expectedValue: Data?
            var buffer = ByteBuffer()
            try? value.encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Data(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, value)
        }
    }

    func testEncodeWithTextFormatProducesHexPrefix() {
        // Arrange
        let value = Data([0xDE, 0xAD, 0xBE, 0xEF])
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer, format: .text)

        // Act
        let encoded = buffer.readString()

        // Assert — PostgreSQL text bytea is always \x + lowercase hex pairs
        XCTAssertEqual(encoded, "\\xdeadbeef")
    }

    func testEncodeWithTextFormatEmptyData() {
        // Arrange
        let value = Data()
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer, format: .text)

        // Act
        let encoded = buffer.readString()

        // Assert
        XCTAssertEqual(encoded, "\\x")
    }

    func testInitWithTextFormatMissingPrefix() {
        // Arrange — hex string without the required \x prefix
        let format: DataFormat = .text
        let type: DataType = .bytea
        var buffer = ByteBuffer()
        buffer.writeString("deadbeef")  // no \x prefix

        // Act/Assert
        XCTAssertThrowsError(try Data(buffer: &buffer, format: format, type: type)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidData(format: format, type: type)).localizedDescription
            )
        }
    }

    func testInitWithTextFormatOddLengthHex() {
        // Arrange — \x followed by an odd number of hex digits is invalid
        let format: DataFormat = .text
        let type: DataType = .bytea
        var buffer = ByteBuffer()
        buffer.writeString("\\xabc")  // odd length after prefix

        // Act/Assert
        XCTAssertThrowsError(try Data(buffer: &buffer, format: format, type: type)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidData(format: format, type: type)).localizedDescription
            )
        }
    }

    func testInitWithTextFormatInvalidHexCharacter() {
        // Arrange — \x followed by invalid (non-hex) characters
        let format: DataFormat = .text
        let type: DataType = .bytea
        var buffer = ByteBuffer()
        buffer.writeString("\\xzz")  // 'z' is not a valid hex digit

        // Act/Assert
        XCTAssertThrowsError(try Data(buffer: &buffer, format: format, type: type)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidData(format: format, type: type)).localizedDescription
            )
        }
    }

    func testInitWithTextFormatUppercaseHex() {
        // Arrange — PostgreSQL can send uppercase hex; decoder should handle it
        let format: DataFormat = .text
        let type: DataType = .bytea
        var buffer = ByteBuffer()
        buffer.writeString("\\xDEADBEEF")

        // Act/Assert
        var result: Data?
        XCTAssertNoThrow(result = try Data(buffer: &buffer, format: format, type: type))
        XCTAssertEqual(result, Data([0xDE, 0xAD, 0xBE, 0xEF]))
    }

    func testInitWithTextFormatEmptyBuffer() {
        // Arrange — empty buffer, no string to read
        let format: DataFormat = .text
        let type: DataType = .bytea
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Data(buffer: &buffer, format: format, type: type)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidData(format: format, type: type)).localizedDescription
            )
        }
    }
}
