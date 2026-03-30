@testable import PostgreSQL
import XCTest

final class ArrayTests: BaseTests {
    func testDefaultFormatAndType() {
        // Arrange
        let format: DataFormat = .binary
        let intArrayType: DataType = MemoryLayout<Int>.size == 8 ? .int8Array : .int4Array

        // Assert
        XCTAssertEqual(Array<Bool>.psqlFormat, format)
        XCTAssertEqual(Array<Bool>.psqlType, .boolArray)

        XCTAssertEqual(Array<Data>.psqlFormat, format)
        XCTAssertEqual(Array<Data>.psqlType, .byteaArray)

        XCTAssertEqual(Array<Double>.psqlFormat, format)
        XCTAssertEqual(Array<Double>.psqlType, .float8Array)

        XCTAssertEqual(Array<Float>.psqlFormat, format)
        XCTAssertEqual(Array<Float>.psqlType, .float4Array)

        XCTAssertEqual(Array<Int>.psqlFormat, format)
        XCTAssertEqual(Array<Int>.psqlType, intArrayType)

        XCTAssertEqual(Array<Int16>.psqlFormat, format)
        XCTAssertEqual(Array<Int16>.psqlType, .int2Array)

        XCTAssertEqual(Array<Int32>.psqlFormat, format)
        XCTAssertEqual(Array<Int32>.psqlType, .int4Array)

        XCTAssertEqual(Array<Int64>.psqlFormat, format)
        XCTAssertEqual(Array<Int64>.psqlType, .int8Array)

        XCTAssertEqual(Array<String>.psqlFormat, format)
        XCTAssertEqual(Array<String>.psqlType, .textArray)

        XCTAssertEqual(Array<UInt8>.psqlFormat, format)
        XCTAssertEqual(Array<UInt8>.psqlType, .charArray)

        XCTAssertEqual(Array<UUID>.psqlFormat, format)
        XCTAssertEqual(Array<UUID>.psqlType, .uuidArray)
    }

    func testInit() {
        testInit(values: Array<Bool>())
        testInit(values: [true, false])

        testInit(values: Array<Data>())
        testInit(values: [Data("a".utf8), Data("b".utf8)])

        testInit(values: Array<Double>())
        testInit(values: [Double(1.2), Double(3)])

        testInit(values: Array<Float>())
        testInit(values: [Float(4.5), Float(6)])

        testInit(values: Array<Int>())
        testInit(values: [Int(7), Int(8)])

        testInit(values: Array<Int16>())
        testInit(values: [Int16(9), Int16(10)])

        testInit(values: Array<Int32>())
        testInit(values: [Int32(11), Int32(12)])

        testInit(values: Array<Int64>())
        testInit(values: [Int64(13), Int64(14)])

        testInit(values: Array<String>())
        testInit(values: ["c", "d"])

        testInit(values: Array<UInt8>())
        testInit(values: [UInt8(ascii: "e"), UInt8(ascii: "f")])

        testInit(values: Array<UUID>())
        testInit(values: [UUID(), UUID()])
    }

    func testInit<T: PostgreSQLCodable & Equatable>(values: [T]) {
        // Arrange
        let format: DataFormat = .binary
        var expectedValues: [T]?
        var buffer = ByteBuffer()
        try? values.encode(into: &buffer, format: format)

        // Act/Assert
        XCTAssertNoThrow(expectedValues = try Array<T>(buffer: &buffer, format: format))
        XCTAssertEqual(expectedValues, values)
    }

    // MARK: Text-format rejection

    func testInitWithTextFormatThrows() {
        // Array only supports binary format; text format must throw.
        var buffer = ByteBuffer()
        try? [Int32(1), Int32(2)].encode(into: &buffer, format: .binary)
        // Re-encode in text format is not supported; just pass a non-empty buffer
        // with format: .text and confirm it throws.
        XCTAssertThrowsError(try Array<Int32>(buffer: &buffer, format: .text)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
        }
    }

    func testEncodeWithTextFormatThrows() {
        let values = [Int32(1), Int32(2)]
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try values.encode(into: &buffer, format: .text, type: .int4Array)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
        }
    }

    // MARK: Invalid data — decode failures

    func testInitWithTruncatedHeader() {
        // Arrange — write only 1 Int32 instead of the required 3
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(1))  // isNotEmpty, but missing format and elementType

        XCTAssertThrowsError(try Array<Int32>(buffer: &buffer, format: .binary)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
        }
    }

    func testInitWithInvalidIsNotEmptyFlag() {
        // Arrange — isNotEmpty must be 0 or 1; 2 is invalid
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(2))      // invalid flag
        buffer.writeInteger(Int32(DataFormat.binary.rawValue))
        buffer.writeInteger(DataType.int4Array.rawValue)

        XCTAssertThrowsError(try Array<Int32>(buffer: &buffer, format: .binary)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
        }
    }

    func testInitWithFormatMismatch() {
        // Arrange — binary payload but elementFormatValue says text (1)
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(1))       // isNotEmpty
        buffer.writeInteger(Int32(1))       // format = text (mismatch with .binary)
        buffer.writeInteger(DataType.int4Array.rawValue)

        XCTAssertThrowsError(try Array<Int32>(buffer: &buffer, format: .binary)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
        }
    }

    func testInitWithInvalidElementDataType() {
        // Arrange — 0xFFFFFFFF is not a valid DataType rawValue
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(1))       // isNotEmpty
        buffer.writeInteger(Int32(DataFormat.binary.rawValue))
        buffer.writeInteger(Int32(bitPattern: 0xFFFFFFFF))  // unknown DataType

        XCTAssertThrowsError(try Array<Int32>(buffer: &buffer, format: .binary)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
        }
    }

    func testInitWithMissingElementData() {
        // Arrange — header says 2 elements but no element data follows
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(1))       // isNotEmpty
        buffer.writeInteger(Int32(DataFormat.binary.rawValue))
        buffer.writeInteger(DataType.int4Array.rawValue)
        buffer.writeInteger(Int32(2))       // elementsCount = 2
        buffer.writeInteger(Int32(1))       // dimensions = 1
        // No element payloads follow — truncated

        XCTAssertThrowsError(try Array<Int32>(buffer: &buffer, format: .binary)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
        }
    }

    func testInitWithInvalidDimensions() {
        // Arrange — multi-dimensional array (dimensions != 1) is unsupported
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(1))       // isNotEmpty
        buffer.writeInteger(Int32(DataFormat.binary.rawValue))
        buffer.writeInteger(DataType.int4Array.rawValue)
        buffer.writeInteger(Int32(1))       // elementsCount = 1
        buffer.writeInteger(Int32(2))       // dimensions = 2 (unsupported)

        XCTAssertThrowsError(try Array<Int32>(buffer: &buffer, format: .binary)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
        }
    }

    func testInitWithZeroElementsCount() {
        // Arrange — isNotEmpty == 1 but elementsCount == 0 is invalid
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(1))       // isNotEmpty
        buffer.writeInteger(Int32(DataFormat.binary.rawValue))
        buffer.writeInteger(DataType.int4Array.rawValue)
        buffer.writeInteger(Int32(0))       // elementsCount = 0 — must be > 0 per spec
        buffer.writeInteger(Int32(1))       // dimensions

        XCTAssertThrowsError(try Array<Int32>(buffer: &buffer, format: .binary)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
        }
    }

    func testInitEmptyArrayRoundTrip() {
        // Encode an empty array and confirm it decodes back as empty
        let values: [Int32] = []
        var buffer = ByteBuffer()
        XCTAssertNoThrow(try values.encode(into: &buffer, format: .binary, type: .int4Array))

        var decoded: [Int32]?
        XCTAssertNoThrow(decoded = try Array<Int32>(buffer: &buffer, format: .binary, type: .int4Array))
        XCTAssertEqual(decoded, [])
    }
}
