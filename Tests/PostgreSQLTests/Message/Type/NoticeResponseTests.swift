@testable import PostgreSQL
import XCTest

final class NoticeResponseTests: BaseTests {
    // MARK: Identifier

    func testIdentifier() {
        // Arrange
        var buffer = ByteBuffer()
        buffer.writeInteger(UInt8(0))

        let noticeResponse = try? Message.NoticeResponse(buffer: &buffer)
        XCTAssertEqual(noticeResponse?.identifier, .backend(.noticeResponse))
    }

    // MARK: Parsing known fields

    func testInitWithKnownFields() {
        // Arrange
        var buffer = ByteBuffer()
        buffer.writeInteger(Message.Field.localizedSeverity.rawValue)
        buffer.writeNullTerminatedString("NOTICE")
        buffer.writeInteger(Message.Field.message.rawValue)
        buffer.writeNullTerminatedString("relation \"bar\" already exists")
        buffer.writeInteger(Message.Field.code.rawValue)
        buffer.writeNullTerminatedString("42P07")
        buffer.writeInteger(UInt8(0))

        // Act
        var noticeResponse: Message.NoticeResponse?
        XCTAssertNoThrow(noticeResponse = try Message.NoticeResponse(buffer: &buffer))

        // Assert
        XCTAssertEqual(noticeResponse?.fields[.localizedSeverity], "NOTICE")
        XCTAssertEqual(noticeResponse?.fields[.message], "relation \"bar\" already exists")
        XCTAssertEqual(noticeResponse?.fields[.code], "42P07")
    }

    // MARK: Unknown field types (fix #40)

    func testInitWithUnknownFieldTypeIsIgnored() {
        // Arrange — unknown field byte followed by a known field
        var buffer = ByteBuffer()
        buffer.writeInteger(UInt8(0xFF))
        buffer.writeNullTerminatedString("ignored")
        buffer.writeInteger(Message.Field.message.rawValue)
        buffer.writeNullTerminatedString("notice message")
        buffer.writeInteger(UInt8(0))

        // Act
        var noticeResponse: Message.NoticeResponse?
        XCTAssertNoThrow(noticeResponse = try Message.NoticeResponse(buffer: &buffer))

        // Assert
        XCTAssertEqual(noticeResponse?.fields[.message], "notice message")
        XCTAssertEqual(noticeResponse?.fields.count, 1)
    }

    func testInitWithMultipleUnknownFieldTypes() {
        // Arrange
        var buffer = ByteBuffer()
        buffer.writeInteger(UInt8(0x03))
        buffer.writeNullTerminatedString("unknown1")
        buffer.writeInteger(UInt8(0x07))
        buffer.writeNullTerminatedString("unknown2")
        buffer.writeInteger(Message.Field.hint.rawValue)
        buffer.writeNullTerminatedString("try this")
        buffer.writeInteger(UInt8(0))

        var noticeResponse: Message.NoticeResponse?
        XCTAssertNoThrow(noticeResponse = try Message.NoticeResponse(buffer: &buffer))
        XCTAssertEqual(noticeResponse?.fields[.hint], "try this")
        XCTAssertEqual(noticeResponse?.fields.count, 1)
    }

    // MARK: Edge cases

    func testInitWithEmptyFields() {
        // Arrange — only null terminator
        var buffer = ByteBuffer()
        buffer.writeInteger(UInt8(0))

        var noticeResponse: Message.NoticeResponse?
        XCTAssertNoThrow(noticeResponse = try Message.NoticeResponse(buffer: &buffer))
        XCTAssertEqual(noticeResponse?.fields.count, 0)
    }

    func testInitWithEmptyBuffer() {
        // Arrange — completely empty buffer
        var buffer = ByteBuffer()

        var noticeResponse: Message.NoticeResponse?
        XCTAssertNoThrow(noticeResponse = try Message.NoticeResponse(buffer: &buffer))
        XCTAssertEqual(noticeResponse?.fields.count, 0)
    }

    func testInitWithMissingNullTerminatedString() {
        // Arrange — field type byte present but no string following it
        var buffer = ByteBuffer()
        buffer.writeInteger(Message.Field.message.rawValue)
        // missing null-terminated string

        XCTAssertThrowsError(try Message.NoticeResponse(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.cantParseNoticeResponseFields).localizedDescription
            )
        }
    }
}
