@testable import PostgreSQL
import XCTest

final class IntTests: BaseTests {
    func testDefaultFormatAndType() {
        // Arrange
        let type: DataType = MemoryLayout<Int>.size == 8 ? .int8 : .int4

        // Assert
        XCTAssertEqual(Int16.psqlFormat, .binary)
        XCTAssertEqual(Int16.psqlType, .int2)
        XCTAssertEqual(Int32.psqlFormat, .binary)
        XCTAssertEqual(Int32.psqlType, .int4)
        XCTAssertEqual(Int64.psqlFormat, .binary)
        XCTAssertEqual(Int64.psqlType, .int8)
        XCTAssertEqual(Int.psqlFormat, .binary)
        XCTAssertEqual(Int.psqlType, type)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .uuid
        let values: [PostgreSQLCodable] = [Int16(1), Int32(1), Int64(1), Int(1)]
        var buffer: ByteBuffer

        for value in values {
            buffer = ByteBuffer()
            try? value.encode(into: &buffer)

            // Act/Assert
            XCTAssertThrowsError(try Int16(buffer: &buffer, type: type)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidDataType(type)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int32(buffer: &buffer, type: type)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidDataType(type)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int64(buffer: &buffer, type: type)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidDataType(type)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int(buffer: &buffer, type: type)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidDataType(type)).localizedDescription
                )
            }
        }
    }

    func testInitWithValidValue() {
        // Arrange
        let value: Int = 1
        var expectedValue: Int?
        var buffer: ByteBuffer

        for format in DataFormat.allCases {
            // Arrange
            buffer = ByteBuffer()
            try? Int16(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = Int(try Int16(buffer: &buffer, format: format, type: .int2)))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? Int16(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = Int(try Int16(buffer: &buffer, format: format)))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? Int16(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = Int(try Int32(buffer: &buffer, format: format, type: .int2)))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? Int32(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = Int(try Int32(buffer: &buffer, format: format, type: .int4)))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? Int32(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = Int(try Int32(buffer: &buffer, format: format)))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? Int16(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = Int(try Int64(buffer: &buffer, format: format, type: .int2)))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? Int32(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = Int(try Int64(buffer: &buffer, format: format, type: .int4)))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? Int64(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = Int(try Int64(buffer: &buffer, format: format, type: .int8)))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? Int64(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = Int(try Int64(buffer: &buffer, format: format)))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? Int16(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int(buffer: &buffer, format: format, type: .int2))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? Int32(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int(buffer: &buffer, format: format, type: .int4))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? Int64(value).encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int(buffer: &buffer, format: format, type: .int8))
            XCTAssertEqual(expectedValue, value)

            // Arrange
            buffer = ByteBuffer()
            try? value.encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try Int(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, value)
        }
    }

    func testInitWithInvalidValue() {
        // Arrange
        let invalidValue = UUID()
        var buffer: ByteBuffer

        for format in DataFormat.allCases {
            buffer = ByteBuffer()
            try? invalidValue.encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertThrowsError(try Int16(buffer: &buffer, format: format, type: .int2)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidData(format: format, type: .int2)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int32(buffer: &buffer, format: format, type: .int2)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidData(format: format, type: .int2)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int32(buffer: &buffer, format: format, type: .int4)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidData(format: format, type: .int4)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int64(buffer: &buffer, format: format, type: .int2)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidData(format: format, type: .int2)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int64(buffer: &buffer, format: format, type: .int4)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidData(format: format, type: .int4)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int64(buffer: &buffer, format: format, type: .int8)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidData(format: format, type: .int8)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int(buffer: &buffer, format: format, type: .int2)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidData(format: format, type: .int2)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int(buffer: &buffer, format: format, type: .int4)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidData(format: format, type: .int4)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int(buffer: &buffer, format: format, type: .int8)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    clientError(.invalidData(format: format, type: .int8)).localizedDescription
                )
            }
        }
    }
}
