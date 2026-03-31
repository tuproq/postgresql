@testable import PostgreSQL
import XCTest

final class MessageTests: BaseTests {
    func testInit() {
        // Arrange
        let messageType = Message.StartupMessage(user: "user", database: "database")
        let type: Message.Kind = .frontend
        var buffer = ByteBuffer()
        messageType.encode(into: &buffer)

        // Act
        let message = Message(
            identifier: messageType.identifier,
            type: type,
            buffer: buffer
        )

        // Assert
        XCTAssertEqual(message.identifier, messageType.identifier)
        XCTAssertEqual(message.type, type)
        XCTAssertEqual(message.buffer, buffer)
    }

    // MARK: Frontend message descriptions
    //
    // Note: FrontendIdentifier and BackendIdentifier are plain UInt8 wrappers.
    // Several identifier names share the same raw byte value; a Swift switch
    // matches the *first* case with that value, so later cases with the same
    // byte are unreachable. The tests below assert what description actually
    // produces — comments mark the colliding groups.

    func testDescriptionForFrontendMessages() {
        // Identifiers with unique byte values — each produces its own name.
        let uniqueCases: [(Message.FrontendIdentifier, String)] = [
            (.bind,        "Bind"),         // 0x42
            (.close,       "Close"),        // 0x43
            (.copyData,    "CopyData"),     // 0x64
            (.copyDone,    "CopyDone"),     // 0x63
            (.copyFail,    "CopyFail"),     // 0x66
            (.describe,    "Describe"),     // 0x44
            (.execute,     "Execute"),      // 0x45
            (.flush,       "Flush"),        // 0x48
            (.functionCall,"FunctionCall"), // 0x46
            (.parse,       "Parse"),        // 0x50
            (.simpleQuery, "SimpleQuery"),  // 0x51
            (.sync,        "Sync"),         // 0x53
            (.terminate,   "Terminate"),    // 0x58
        ]

        for (identifier, expectedName) in uniqueCases {
            let message = Message(
                identifier: .frontend(identifier),
                type: .frontend,
                buffer: ByteBuffer()
            )
            XCTAssertTrue(
                message.description.contains(expectedName),
                "Expected '\(expectedName)' in description, got: '\(message.description)'"
            )
        }

        // 0x70 collision group — .gssResponse / .password / .saslInitialResponse / .saslResponse
        // .gssResponse appears first in the switch and wins for all four.
        for identifier: Message.FrontendIdentifier in [.gssResponse, .password, .saslInitialResponse, .saslResponse] {
            let message = Message(identifier: .frontend(identifier), type: .frontend, buffer: ByteBuffer())
            XCTAssertTrue(
                message.description.contains("GSSResponse"),
                "Expected 'GSSResponse' (first 0x70 case) in description, got: '\(message.description)'"
            )
        }
    }

    func testDescriptionForSSLRequestAndStartupMessage() {
        // Both .sslRequest and .startupMessage have raw value 0x00.
        // .sslRequest appears first in the switch, so both messages produce
        // the same name ("SSLRequest") and the identifier is omitted from the
        // description (the special-case guard at the end of description fires
        // for both because they compare equal via their shared 0x00 value).
        let sslRequest = Message(
            identifier: .frontend(.sslRequest),
            type: .frontend,
            buffer: ByteBuffer()
        )
        XCTAssertEqual(sslRequest.description, "SSLRequest")

        let startupMessage = Message(
            identifier: .frontend(.startupMessage),
            type: .frontend,
            buffer: ByteBuffer()
        )
        // .startupMessage (0x00) hits case .sslRequest first → name = "SSLRequest"
        XCTAssertEqual(startupMessage.description, "SSLRequest")
    }

    func testDescriptionForUnknownFrontendIdentifier() {
        // An identifier that matches none of the named cases gets "Unknown(…)"
        let unknownByte: UInt8 = 0x7F
        let message = Message(
            identifier: .frontend(.init(unknownByte)),
            type: .frontend,
            buffer: ByteBuffer()
        )
        XCTAssertTrue(message.description.contains("Unknown"))
    }

    // MARK: Backend message descriptions

    func testDescriptionForBackendMessages() {
        // Identifiers with unique byte values — each produces its own name.
        let uniqueCases: [(Message.BackendIdentifier, String)] = [
            (.authentication,          "Authentication"),           // 0x52
            (.backendKeyData,          "BackendKeyData"),           // 0x4B
            (.bindComplete,            "BindComplete"),             // 0x32
            (.closeComplete,           "CloseComplete"),            // 0x33
            (.commandComplete,         "CommandComplete"),          // 0x43
            (.copyBothResponse,        "CopyBothResponse"),         // 0x57
            (.copyData,                "CopyData"),                 // 0x64
            (.copyDone,                "CopyDone"),                 // 0x63
            (.copyInResponse,          "CopyInResponse"),           // 0x47
            (.copyOutResponse,         "CopyOutResponse"),          // 0x48
            (.dataRow,                 "DataRow"),                  // 0x44
            (.emptyQueryResponse,      "EmptyQueryResponse"),       // 0x49
            (.errorResponse,           "ErrorResponse"),            // 0x45
            (.functionCallResponse,    "FunctionCallResponse"),     // 0x56
            (.negotiateProtocolVersion,"NegotiateProtocolVersion"), // 0x76
            (.noData,                  "NoData"),                   // 0x6E
            (.notificationResponse,    "NotificationResponse"),     // 0x41
            (.parameterDescription,    "ParameterDescription"),     // 0x74
            (.parseComplete,           "ParseComplete"),            // 0x31
            (.portalSuspended,         "PortalSuspended"),          // 0x73
            (.readyForQuery,           "ReadyForQuery"),            // 0x5A
            (.rowDescription,          "RowDescription"),           // 0x54
        ]

        for (identifier, expectedName) in uniqueCases {
            let message = Message(
                identifier: .backend(identifier),
                type: .backend,
                buffer: ByteBuffer()
            )
            XCTAssertTrue(
                message.description.contains(expectedName),
                "Expected '\(expectedName)' in description, got: '\(message.description)'"
            )
        }

        // .sslSupported and .sslUnsupported now carry synthetic byte values (0xFE / 0xFF)
        // that don't collide with .parameterStatus (0x53) or .noticeResponse (0x4E), so
        // each identifier gets its own description string.
        let sslSupportedMessage = Message(identifier: .backend(.sslSupported), type: .backend, buffer: ByteBuffer())
        XCTAssertTrue(
            sslSupportedMessage.description.contains("SSLSupported"),
            "Expected 'SSLSupported' in description, got: '\(sslSupportedMessage.description)'"
        )

        let sslUnsupportedMessage = Message(identifier: .backend(.sslUnsupported), type: .backend, buffer: ByteBuffer())
        XCTAssertTrue(
            sslUnsupportedMessage.description.contains("SSLUnsupported"),
            "Expected 'SSLUnsupported' in description, got: '\(sslUnsupportedMessage.description)'"
        )

        let parameterStatusMessage = Message(identifier: .backend(.parameterStatus), type: .backend, buffer: ByteBuffer())
        XCTAssertTrue(
            parameterStatusMessage.description.contains("ParameterStatus"),
            "Expected 'ParameterStatus' in description, got: '\(parameterStatusMessage.description)'"
        )

        let noticeResponseMessage = Message(identifier: .backend(.noticeResponse), type: .backend, buffer: ByteBuffer())
        XCTAssertTrue(
            noticeResponseMessage.description.contains("NoticeResponse"),
            "Expected 'NoticeResponse' in description, got: '\(noticeResponseMessage.description)'"
        )
    }

    func testDescriptionForUnknownBackendIdentifier() {
        let unknownByte: UInt8 = 0x7F
        let message = Message(
            identifier: .backend(.init(unknownByte)),
            type: .backend,
            buffer: ByteBuffer()
        )
        XCTAssertTrue(message.description.contains("Unknown"))
    }

    // MARK: Equatable

    func testEquality() {
        let buffer = ByteBuffer()
        let identifier = Message.Identifier.frontend(.parse)

        let a = Message(identifier: identifier, type: .frontend, buffer: buffer)
        let b = Message(identifier: identifier, type: .frontend, buffer: buffer)
        XCTAssertEqual(a, b)
    }

    func testInequality() {
        let buffer = ByteBuffer()
        let a = Message(identifier: .frontend(.parse), type: .frontend, buffer: buffer)
        let b = Message(identifier: .frontend(.bind), type: .frontend, buffer: buffer)
        XCTAssertNotEqual(a, b)
    }
}
