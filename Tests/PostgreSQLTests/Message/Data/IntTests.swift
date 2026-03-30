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
                    postgreSQLError(.invalidDataType(type)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int32(buffer: &buffer, type: type)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidDataType(type)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int64(buffer: &buffer, type: type)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidDataType(type)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int(buffer: &buffer, type: type)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidDataType(type)).localizedDescription
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
                    postgreSQLError(.invalidData(format: format, type: .int2)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int32(buffer: &buffer, format: format, type: .int2)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidData(format: format, type: .int2)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int32(buffer: &buffer, format: format, type: .int4)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidData(format: format, type: .int4)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int64(buffer: &buffer, format: format, type: .int2)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidData(format: format, type: .int2)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int64(buffer: &buffer, format: format, type: .int4)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidData(format: format, type: .int4)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int64(buffer: &buffer, format: format, type: .int8)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidData(format: format, type: .int8)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int(buffer: &buffer, format: format, type: .int2)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidData(format: format, type: .int2)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int(buffer: &buffer, format: format, type: .int4)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidData(format: format, type: .int4)).localizedDescription
                )
            }
            XCTAssertThrowsError(try Int(buffer: &buffer, format: format, type: .int8)) { error in
                XCTAssertNotNil(error as? PostgreSQLError)
                XCTAssertEqual(
                    error.localizedDescription,
                    postgreSQLError(.invalidData(format: format, type: .int8)).localizedDescription
                )
            }
        }
    }

    // MARK: Encode overflow / narrowing errors

    func testInt32EncodeToBinaryInt2Overflow() {
        // Arrange — a value that doesn't fit in Int16
        let value = Int32(Int16.max) + 1  // 32768
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try value.encode(into: &buffer, format: .binary, type: .int2)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidData(format: .binary, type: .int2)).localizedDescription
            )
        }
    }

    func testInt64EncodeToBinaryInt2Overflow() {
        // Arrange — Int64 value that can't be narrowed to Int16
        let value = Int64(Int16.max) + 1
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try value.encode(into: &buffer, format: .binary, type: .int2)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidData(format: .binary, type: .int2)).localizedDescription
            )
        }
    }

    func testInt64EncodeToBinaryInt4Overflow() {
        // Arrange — Int64 value that can't be narrowed to Int32
        let value = Int64(Int32.max) + 1
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try value.encode(into: &buffer, format: .binary, type: .int4)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidData(format: .binary, type: .int4)).localizedDescription
            )
        }
    }

    func testIntEncodeToBinaryInt2Overflow() {
        // Arrange
        let value = Int(Int16.max) + 1
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try value.encode(into: &buffer, format: .binary, type: .int2)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidData(format: .binary, type: .int2)).localizedDescription
            )
        }
    }

    func testIntEncodeToBinaryInt4Overflow() {
        // Arrange — only meaningful on 64-bit platforms where Int is 64-bit
        guard MemoryLayout<Int>.size == 8 else { return }
        let value = Int(Int32.max) + 1
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try value.encode(into: &buffer, format: .binary, type: .int4)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidData(format: .binary, type: .int4)).localizedDescription
            )
        }
    }

    func testInt32EncodeWithInvalidBinaryType() {
        // Arrange — binary + unsupported type
        let value = Int32(1)
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try value.encode(into: &buffer, format: .binary, type: .uuid)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidDataType(.uuid)).localizedDescription
            )
        }
    }

    func testInt32EncodeWithInvalidTextType() {
        // Arrange — text + unsupported type
        let value = Int32(1)
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try value.encode(into: &buffer, format: .text, type: .uuid)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidDataType(.uuid)).localizedDescription
            )
        }
    }

    func testInt64EncodeWithInvalidBinaryType() {
        let value = Int64(1)
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try value.encode(into: &buffer, format: .binary, type: .uuid)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidDataType(.uuid)).localizedDescription
            )
        }
    }

    func testInt64EncodeWithInvalidTextType() {
        let value = Int64(1)
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try value.encode(into: &buffer, format: .text, type: .uuid)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidDataType(.uuid)).localizedDescription
            )
        }
    }

    func testIntEncodeWithInvalidBinaryType() {
        let value = Int(1)
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try value.encode(into: &buffer, format: .binary, type: .uuid)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidDataType(.uuid)).localizedDescription
            )
        }
    }

    func testIntEncodeWithInvalidTextType() {
        let value = Int(1)
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try value.encode(into: &buffer, format: .text, type: .uuid)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidDataType(.uuid)).localizedDescription
            )
        }
    }

    // MARK: Int32 OID type

    func testInt32EncodeAndDecodeAsOID() {
        // Arrange — OID is a valid type for Int32
        let value = Int32(12345)
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer, format: .binary, type: .oid)

        var decoded: Int32?
        XCTAssertNoThrow(decoded = try Int32(buffer: &buffer, format: .binary, type: .oid))
        XCTAssertEqual(decoded, value)
    }

    func testInt32EncodeAndDecodeAsOIDText() {
        let value = Int32(12345)
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer, format: .text, type: .oid)

        var decoded: Int32?
        XCTAssertNoThrow(decoded = try Int32(buffer: &buffer, format: .text, type: .oid))
        XCTAssertEqual(decoded, value)
    }
}
