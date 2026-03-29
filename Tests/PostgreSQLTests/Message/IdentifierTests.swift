@testable import PostgreSQL
import XCTest

final class MessageIdentifierTests: BaseTests {
    func testFrontendIdentifierValues() {
        let cases: [(UInt8, Message.FrontendIdentifier)] = [
            (0x42, .bind),
            (0x43, .close),
            (0x64, .copyData),
            (0x63, .copyDone),
            (0x66, .copyFail),
            (0x44, .describe),
            (0x45, .execute),
            (0x48, .flush),
            (0x46, .functionCall),
            (0x70, .gssResponse),
            (0x50, .parse),
            (0x70, .password),
            (0x70, .saslInitialResponse),
            (0x70, .saslResponse),
            (0x51, .simpleQuery),
            (0x00, .sslRequest),
            (0x00, .startupMessage),
            (0x53, .sync),
            (0x58, .terminate)
        ]

        for (expectedByte, frontendIdentifier) in cases {
            XCTAssertEqual(frontendIdentifier.value, expectedByte)
            XCTAssertEqual(Message.Identifier.frontend(frontendIdentifier).value, expectedByte)
        }
    }

    func testBackendIdentifierValues() {
        let cases: [(UInt8, Message.BackendIdentifier)] = [
            (0x52, .authentication),
            (0x4B, .backendKeyData),
            (0x32, .bindComplete),
            (0x33, .closeComplete),
            (0x43, .commandComplete),
            (0x57, .copyBothResponse),
            (0x64, .copyData),
            (0x63, .copyDone),
            (0x47, .copyInResponse),
            (0x48, .copyOutResponse),
            (0x44, .dataRow),
            (0x49, .emptyQueryResponse),
            (0x45, .errorResponse),
            (0x56, .functionCallResponse),
            (0x76, .negotiateProtocolVersion),
            (0x6E, .noData),
            (0x4E, .noticeResponse),
            (0x41, .notificationResponse),
            (0x74, .parameterDescription),
            (0x53, .parameterStatus),
            (0x31, .parseComplete),
            (0x73, .portalSuspended),
            (0x5A, .readyForQuery),
            (0x54, .rowDescription),
            (0x53, .sslSupported),
            (0x4E, .sslUnsupported)
        ]

        for (expectedByte, backendIdentifier) in cases {
            XCTAssertEqual(backendIdentifier.value, expectedByte)
            XCTAssertEqual(Message.Identifier.backend(backendIdentifier).value, expectedByte)
        }
    }

    func testDirectionDistinction() {
        // Byte 0x43 is both Close (frontend) and CommandComplete (backend).
        // The tagged enum must treat them as distinct values.
        let close = Message.Identifier.frontend(.close)
        let commandComplete = Message.Identifier.backend(.commandComplete)
        XCTAssertEqual(close.value, commandComplete.value)
        XCTAssertNotEqual(close, commandComplete)

        // Byte 0x44: Describe vs DataRow
        let describe = Message.Identifier.frontend(.describe)
        let dataRow = Message.Identifier.backend(.dataRow)
        XCTAssertEqual(describe.value, dataRow.value)
        XCTAssertNotEqual(describe, dataRow)

        // Byte 0x45: Execute vs ErrorResponse
        let execute = Message.Identifier.frontend(.execute)
        let errorResponse = Message.Identifier.backend(.errorResponse)
        XCTAssertEqual(execute.value, errorResponse.value)
        XCTAssertNotEqual(execute, errorResponse)
    }
}
