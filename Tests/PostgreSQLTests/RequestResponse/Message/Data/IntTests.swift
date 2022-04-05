import NIOCore
@testable import PostgreSQL
import XCTest

final class IntTests: BaseTests {
    func testDefaultFormatAndType() {
        // Arrange
        var type: DataType?

        switch MemoryLayout<Int>.size {
        case 4: type = .int4
        case 8: type = .int8
        default: break
        }

        // Assert
        XCTAssertEqual(Int.psqlFormat, .binary)
        XCTAssertEqual(Int.psqlType, type)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .uuid
        let value: Int = 1
        var buffer = ByteBuffer()
        value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try Int(buffer: &buffer, type: type)) { error in
            XCTAssertEqual(
                error.localizedDescription,
                PostgreSQL.error(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let formats = DataFormat.allCases
        var expectedValue: Int?

        for format in formats {
            // Arrange
            let value: Int16 = 1
            let type: DataType = .int2
            var buffer = ByteBuffer()
            value.encode(into: &buffer, with: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int(buffer: &buffer, format: format, type: type))
            XCTAssertEqual(expectedValue, Int(value))
        }

        for format in formats {
            // Arrange
            let value: Int32 = 1
            let type: DataType = .int4
            var buffer = ByteBuffer()
            value.encode(into: &buffer, with: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int(buffer: &buffer, format: format, type: type))
            XCTAssertEqual(expectedValue, Int(value))
        }

        for format in formats {
            // Arrange
            let value: Int64 = 1
            let type: DataType = .int8
            var buffer = ByteBuffer()
            value.encode(into: &buffer, with: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int(buffer: &buffer, format: format, type: type))
            XCTAssertEqual(expectedValue, Int(value))
        }

        for format in formats {
            // Arrange
            let value: Int = 1
            var buffer = ByteBuffer()
            value.encode(into: &buffer, with: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, value)
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValue = UUID()
        let types: [DataType] = [.int2, .int4, .int8]

        for format in DataFormat.allCases {
            for type in types {
                var buffer = ByteBuffer()
                invalidValue.encode(into: &buffer, with: format)

                // Act/Assert
                XCTAssertThrowsError(try Int(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertEqual(
                        error.localizedDescription,
                        PostgreSQL.error(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }
}
