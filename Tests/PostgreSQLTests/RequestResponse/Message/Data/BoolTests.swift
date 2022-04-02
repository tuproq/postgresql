import NIOCore
@testable import PostgreSQL
import XCTest

final class BoolTests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(Bool.psqlFormat, .binary)
        XCTAssertEqual(Bool.psqlType, .bool)
    }

    func testInitWithValidInputs() {
        // Arrange
        let values = [false, true]

        for format in DataFormat.allCases {
            for value in values {
                var expectedValue: Bool?
                var buffer = ByteBuffer()
                value.encode(into: &buffer, with: format)

                // Act/Assert
                XCTAssertNoThrow(expectedValue = try Bool(buffer: &buffer, format: format))
                XCTAssertEqual(expectedValue, value)
            }
        }
    }

    func testInitWithInvalidInputs() {
        // Arrange
        let formats = DataFormat.allCases
        let type: DataType = .bool
        let invalidType: DataType = .text
        let text = "text"
        let int: UInt8 = 2
        var buffer = ByteBuffer()
        int.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try Bool(buffer: &buffer, type: invalidType)) { error in
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidDataType(invalidType)).localizedDescription
            )
        }

        for format in formats {
            var buffer = ByteBuffer()
            text.encode(into: &buffer)

            XCTAssertThrowsError(try Bool(buffer: &buffer, format: format, type: type)) { error in
                XCTAssertEqual(
                    error.localizedDescription,
                    PostgreSQL.error(.invalidData(format: format, type: type)).localizedDescription
                )
            }
        }

        for format in formats {
            var buffer = ByteBuffer()
            int.encode(into: &buffer)

            XCTAssertThrowsError(try Bool(buffer: &buffer, format: format, type: type)) { error in
                XCTAssertEqual(
                    error.localizedDescription,
                    PostgreSQL.error(.invalidData(format: format, type: type)).localizedDescription
                )
            }
        }
    }

    func testEncode() {
        // Arrange
        let values = [false, true]
        let expectedValues: [DataFormat: [UInt8]] = [
            .binary: [0, 1],
            .text: [UInt8(ascii: "f"), UInt8(ascii: "t")]
        ]

        for format in DataFormat.allCases {
            for (index, value) in values.enumerated() {
                // Act
                let expectedValue = expectedValues[format]?[index]
                var buffer = ByteBuffer()
                value.encode(into: &buffer, with: format)

                // Assert
                XCTAssertEqual(buffer.readableBytes, 1)
                XCTAssertEqual(expectedValue, buffer.getInteger(at: buffer.readerIndex, as: UInt8.self))
            }
        }
    }
}
