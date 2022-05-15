@testable import PostgreSQL
import XCTest

final class DataTypeTests: BaseTests {
    func testCases() {
        // Assert
        XCTAssertEqual(DataType.allCases.count, 44)
        XCTAssertEqual(DataType.null.rawValue, 0)
        XCTAssertEqual(DataType.null.description, "null")
        XCTAssertEqual(DataType.bool.rawValue, 16)
        XCTAssertEqual(DataType.bool.description, "bool")
        XCTAssertEqual(DataType.bytea.rawValue, 17)
        XCTAssertEqual(DataType.bytea.description, "bytea")
        XCTAssertEqual(DataType.char.rawValue, 18)
        XCTAssertEqual(DataType.char.description, "char")
        XCTAssertEqual(DataType.name.rawValue, 19)
        XCTAssertEqual(DataType.name.description, "name")
        XCTAssertEqual(DataType.int8.rawValue, 20)
        XCTAssertEqual(DataType.int8.description, "int8")
        XCTAssertEqual(DataType.int2.rawValue, 21)
        XCTAssertEqual(DataType.int2.description, "int2")
        XCTAssertEqual(DataType.int4.rawValue, 23)
        XCTAssertEqual(DataType.int4.description, "int4")
        XCTAssertEqual(DataType.regproc.rawValue, 24)
        XCTAssertEqual(DataType.regproc.description, "regproc")
        XCTAssertEqual(DataType.text.rawValue, 25)
        XCTAssertEqual(DataType.text.description, "text")
        XCTAssertEqual(DataType.oid.rawValue, 26)
        XCTAssertEqual(DataType.oid.description, "oid")
        XCTAssertEqual(DataType.json.rawValue, 114)
        XCTAssertEqual(DataType.json.description, "json")
        XCTAssertEqual(DataType.pgNodeTree.rawValue, 194)
        XCTAssertEqual(DataType.pgNodeTree.description, "pgNodeTree")
        XCTAssertEqual(DataType.point.rawValue, 600)
        XCTAssertEqual(DataType.point.description, "point")
        XCTAssertEqual(DataType.float4.rawValue, 700)
        XCTAssertEqual(DataType.float4.description, "float4")
        XCTAssertEqual(DataType.float8.rawValue, 701)
        XCTAssertEqual(DataType.float8.description, "float8")
        XCTAssertEqual(DataType.money.rawValue, 790)
        XCTAssertEqual(DataType.money.description, "money")
        XCTAssertEqual(DataType.boolArray.rawValue, 1000)
        XCTAssertEqual(DataType.boolArray.description, "boolArray")
        XCTAssertEqual(DataType.byteaArray.rawValue, 1001)
        XCTAssertEqual(DataType.byteaArray.description, "byteaArray")
        XCTAssertEqual(DataType.charArray.rawValue, 1002)
        XCTAssertEqual(DataType.charArray.description, "charArray")
        XCTAssertEqual(DataType.nameArray.rawValue, 1003)
        XCTAssertEqual(DataType.nameArray.description, "nameArray")
        XCTAssertEqual(DataType.int2Array.rawValue, 1005)
        XCTAssertEqual(DataType.int2Array.description, "int2Array")
        XCTAssertEqual(DataType.int4Array.rawValue, 1007)
        XCTAssertEqual(DataType.int4Array.description, "int4Array")
        XCTAssertEqual(DataType.textArray.rawValue, 1009)
        XCTAssertEqual(DataType.textArray.description, "textArray")
        XCTAssertEqual(DataType.varcharArray.rawValue, 1015)
        XCTAssertEqual(DataType.varcharArray.description, "varcharArray")
        XCTAssertEqual(DataType.int8Array.rawValue, 1016)
        XCTAssertEqual(DataType.int8Array.description, "int8Array")
        XCTAssertEqual(DataType.pointArray.rawValue, 1017)
        XCTAssertEqual(DataType.pointArray.description, "pointArray")
        XCTAssertEqual(DataType.float4Array.rawValue, 1021)
        XCTAssertEqual(DataType.float4Array.description, "float4Array")
        XCTAssertEqual(DataType.float8Array.rawValue, 1022)
        XCTAssertEqual(DataType.float8Array.description, "float8Array")
        XCTAssertEqual(DataType.aclitemArray.rawValue, 1034)
        XCTAssertEqual(DataType.aclitemArray.description, "aclitemArray")
        XCTAssertEqual(DataType.bpchar.rawValue, 1042)
        XCTAssertEqual(DataType.bpchar.description, "bpchar")
        XCTAssertEqual(DataType.varchar.rawValue, 1043)
        XCTAssertEqual(DataType.varchar.description, "varchar")
        XCTAssertEqual(DataType.date.rawValue, 1082)
        XCTAssertEqual(DataType.date.description, "date")
        XCTAssertEqual(DataType.time.rawValue, 1083)
        XCTAssertEqual(DataType.time.description, "time")
        XCTAssertEqual(DataType.timestamp.rawValue, 1114)
        XCTAssertEqual(DataType.timestamp.description, "timestamp")
        XCTAssertEqual(DataType.timestampArray.rawValue, 1115)
        XCTAssertEqual(DataType.timestampArray.description, "timestampArray")
        XCTAssertEqual(DataType.timestamptz.rawValue, 1184)
        XCTAssertEqual(DataType.timestamptz.description, "timestamptz")
        XCTAssertEqual(DataType.timetz.rawValue, 1266)
        XCTAssertEqual(DataType.timetz.description, "timetz")
        XCTAssertEqual(DataType.numeric.rawValue, 1700)
        XCTAssertEqual(DataType.numeric.description, "numeric")
        XCTAssertEqual(DataType.void.rawValue, 2278)
        XCTAssertEqual(DataType.void.description, "void")
        XCTAssertEqual(DataType.uuid.rawValue, 2950)
        XCTAssertEqual(DataType.uuid.description, "uuid")
        XCTAssertEqual(DataType.uuidArray.rawValue, 2951)
        XCTAssertEqual(DataType.uuidArray.description, "uuidArray")
        XCTAssertEqual(DataType.jsonb.rawValue, 3802)
        XCTAssertEqual(DataType.jsonb.description, "jsonb")
        XCTAssertEqual(DataType.jsonbArray.rawValue, 3807)
        XCTAssertEqual(DataType.jsonbArray.description, "jsonbArray")
    }
}