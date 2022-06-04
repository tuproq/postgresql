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

    func testInit<T: Codable & Equatable>(values: [T]) {
        // Arrange
        let format: DataFormat = .binary
        var expectedValues: [T]?
        var buffer = ByteBuffer()
        try? values.encode(into: &buffer, format: format)

        // Act/Assert
        XCTAssertNoThrow(expectedValues = try Array<T>(buffer: &buffer, format: format))
        XCTAssertEqual(expectedValues, values)
    }
}
