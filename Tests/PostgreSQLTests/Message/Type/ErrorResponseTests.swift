@testable import PostgreSQL
import XCTest

final class ErrorResponseTests: BaseTests {
    // MARK: Identifier

    func testIdentifier() {
        // Arrange
        var buffer = ByteBuffer()
        buffer.writeInteger(UInt8(0))  // null terminator — empty fields list

        // Act
        let errorResponse = try? Message.ErrorResponse(buffer: &buffer)

        // Assert
        XCTAssertEqual(errorResponse?.identifier, .backend(.errorResponse))
    }

    // MARK: Parsing known fields

    func testInitWithKnownFields() {
        // Arrange — build a wire payload containing the message and severity fields
        var buffer = ByteBuffer()
        // Severity field ('S')
        buffer.writeInteger(Message.Field.localizedSeverity.rawValue)
        buffer.writeNullTerminatedString("ERROR")
        // Message field ('M')
        buffer.writeInteger(Message.Field.message.rawValue)
        buffer.writeNullTerminatedString("relation \"foo\" does not exist")
        // Code field ('C')
        buffer.writeInteger(Message.Field.code.rawValue)
        buffer.writeNullTerminatedString("42P01")
        // Null terminator
        buffer.writeInteger(UInt8(0))

        // Act
        var errorResponse: Message.ErrorResponse?
        XCTAssertNoThrow(errorResponse = try Message.ErrorResponse(buffer: &buffer))

        // Assert
        XCTAssertEqual(errorResponse?.fields[.localizedSeverity], "ERROR")
        XCTAssertEqual(errorResponse?.fields[.message], "relation \"foo\" does not exist")
        XCTAssertEqual(errorResponse?.fields[.code], "42P01")
    }

    func testInitWithAllKnownFieldTypes() {
        // Arrange — write every known field type
        let fieldMap: [Message.Field: String] = [
            .localizedSeverity: "ERROR",
            .severity: "ERROR",
            .code: "42P01",
            .message: "test error",
            .detail: "some detail",
            .hint: "a hint",
            .position: "1",
            .internalPosition: "2",
            .internalQuery: "SELECT 1",
            .where: "somewhere",
            .schemaName: "public",
            .tableName: "users",
            .columnName: "id",
            .dataTypeName: "integer",
            .constraintName: "users_pkey",
            .file: "tablecmds.c",
            .line: "123",
            .routine: "SomeRoutine"
        ]

        var buffer = ByteBuffer()
        for (field, value) in fieldMap {
            buffer.writeInteger(field.rawValue)
            buffer.writeNullTerminatedString(value)
        }
        buffer.writeInteger(UInt8(0))

        // Act
        var errorResponse: Message.ErrorResponse?
        XCTAssertNoThrow(errorResponse = try Message.ErrorResponse(buffer: &buffer))

        // Assert
        for (field, value) in fieldMap {
            XCTAssertEqual(errorResponse?.fields[field], value, "Field \(field) mismatch")
        }
    }

    // MARK: Unknown field types (fix #40)

    func testInitWithUnknownFieldTypeIsIgnored() {
        // Arrange — an unknown field type byte (e.g. 0x01) followed by a known one
        var buffer = ByteBuffer()
        // Unknown field type — should be consumed and ignored, not throw
        buffer.writeInteger(UInt8(0x01))
        buffer.writeNullTerminatedString("ignored value")
        // Known field after the unknown one — must still be parsed
        buffer.writeInteger(Message.Field.message.rawValue)
        buffer.writeNullTerminatedString("actual message")
        buffer.writeInteger(UInt8(0))

        // Act
        var errorResponse: Message.ErrorResponse?
        XCTAssertNoThrow(errorResponse = try Message.ErrorResponse(buffer: &buffer))

        // Assert — the known field is present; the unknown one is simply absent
        XCTAssertEqual(errorResponse?.fields[.message], "actual message")
        XCTAssertEqual(errorResponse?.fields.count, 1)
    }

    func testInitWithMultipleUnknownFieldTypes() {
        // Arrange — multiple consecutive unknown field type bytes
        var buffer = ByteBuffer()
        buffer.writeInteger(UInt8(0x01))
        buffer.writeNullTerminatedString("first unknown")
        buffer.writeInteger(UInt8(0x02))
        buffer.writeNullTerminatedString("second unknown")
        buffer.writeInteger(Message.Field.message.rawValue)
        buffer.writeNullTerminatedString("real message")
        buffer.writeInteger(UInt8(0))

        var errorResponse: Message.ErrorResponse?
        XCTAssertNoThrow(errorResponse = try Message.ErrorResponse(buffer: &buffer))
        XCTAssertEqual(errorResponse?.fields[.message], "real message")
        XCTAssertEqual(errorResponse?.fields.count, 1)
    }

    // MARK: Empty and edge cases

    func testInitWithEmptyFields() {
        // Arrange — only the null terminator (no fields)
        var buffer = ByteBuffer()
        buffer.writeInteger(UInt8(0))

        var errorResponse: Message.ErrorResponse?
        XCTAssertNoThrow(errorResponse = try Message.ErrorResponse(buffer: &buffer))
        XCTAssertEqual(errorResponse?.fields.count, 0)
    }

    func testInitWithEmptyBuffer() {
        // Arrange — completely empty buffer; loop exits immediately when readInteger returns nil
        var buffer = ByteBuffer()

        var errorResponse: Message.ErrorResponse?
        XCTAssertNoThrow(errorResponse = try Message.ErrorResponse(buffer: &buffer))
        XCTAssertEqual(errorResponse?.fields.count, 0)
    }

    func testInitWithMissingNullTerminatedString() {
        // Arrange — field type byte present but the null-terminated string is missing
        var buffer = ByteBuffer()
        buffer.writeInteger(Message.Field.message.rawValue)
        // deliberately omit the null-terminated string

        // Act/Assert
        XCTAssertThrowsError(try Message.ErrorResponse(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.cantParseErrorResponseFields).localizedDescription
            )
        }
    }
}
