@testable import PostgreSQL
import XCTest

final class MessageIdentifierTests: BaseTests {
    func testIdentifiers() {
        // Arrange
        let identifiers: [(UInt8, Message.Identifier)] = [
            (0x52, .authentication),
            (0x4B, .backendKeyData),
            (0x42, .bind),
            (0x32, .bindComplete),
            (0x43, .close),
            (0x33, .closeComplete),
            (0x43, .commandComplete),
            (0x57, .copyBothResponse),
            (0x64, .copyData),
            (0x63, .copyDone),
            (0x66, .copyFail),
            (0x47, .copyInResponse),
            (0x48, .copyOutResponse),
            (0x44, .dataRow),
            (0x44, .describe),
            (0x49, .emptyQueryResponse),
            (0x45, .errorResponse),
            (0x45, .execute),
            (0x48, .flush),
            (0x46, .functionCall),
            (0x56, .functionCallResponse),
            (0x70, .gssResponse),
            (0x76, .negotiateProtocolVersion),
            (0x6E, .noData),
            (0x4E, .noticeResponse),
            (0x41, .notificationResponse),
            (0x74, .parameterDescription),
            (0x53, .parameterStatus),
            (0x50, .parse),
            (0x31, .parseComplete),
            (0x70, .password),
            (0x73, .portalSuspended),
            (0x5A, .readyForQuery),
            (0x54, .rowDescription),
            (0x51, .simpleQuery),
            (0x70, .saslInitialResponse),
            (0x70, .saslResponse),
            (0x00, .sslRequest),
            (0x00, .startupMessage),
            (0x53, .sync),
            (0x58, .terminate)
        ]

        // Assert
        for identifier in identifiers {
            XCTAssertEqual(identifier.0, identifier.1.value)
            XCTAssertEqual(Message.Identifier(integerLiteral: identifier.0).value, identifier.1.value)
            XCTAssertEqual(Message.Identifier(integerLiteral: identifier.0).description, identifier.1.description)
        }
    }
}
