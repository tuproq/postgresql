@testable import PostgreSQL
import XCTest

final class AuthenticationTests: BaseTests {
    // MARK: Identifier

    func testIdentifier() {
        // Arrange — .ok is the simplest kind to construct
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(0))  // AuthenticationOk

        let auth = try? Message.Authentication(buffer: &buffer)
        XCTAssertEqual(auth?.identifier, .backend(.authentication))
    }

    // MARK: .ok (rawValue == 0)

    func testInitOk() {
        // Arrange
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(0))

        // Act
        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        // Assert
        if case .ok = auth?.kind { } else {
            XCTFail("Expected .ok, got \(String(describing: auth?.kind))")
        }
    }

    // MARK: .cleartext (rawValue == 3)

    func testInitCleartext() {
        // Arrange
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(3))

        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        if case .cleartext = auth?.kind { } else {
            XCTFail("Expected .cleartext, got \(String(describing: auth?.kind))")
        }
    }

    // MARK: .md5 (rawValue == 5)

    func testInitMD5() {
        // Arrange
        let salt: [UInt8] = [0x01, 0x02, 0x03, 0x04]
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(5))
        buffer.writeBytes(salt)

        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        if case .md5(let parsedSalt) = auth?.kind {
            XCTAssertEqual(parsedSalt, salt)
        } else {
            XCTFail("Expected .md5, got \(String(describing: auth?.kind))")
        }
    }

    func testInitMD5MissingSalt() {
        // Arrange — rawValue 5 but no salt bytes
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(5))
        // salt bytes intentionally omitted

        XCTAssertThrowsError(try Message.Authentication(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.cantParseAuthenticationMethod).localizedDescription
            )
        }
    }

    // MARK: .sasl (rawValue == 10)

    func testInitSASL() {
        // Arrange
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(10))
        buffer.writeNullTerminatedString("SCRAM-SHA-256")
        buffer.writeNullTerminatedString("SCRAM-SHA-256-PLUS")
        buffer.writeNullTerminatedString("")  // empty string terminates the list

        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        if case .sasl(let mechanisms) = auth?.kind {
            XCTAssertEqual(mechanisms, ["SCRAM-SHA-256", "SCRAM-SHA-256-PLUS"])
        } else {
            XCTFail("Expected .sasl, got \(String(describing: auth?.kind))")
        }
    }

    func testInitSASLSingleMechanism() {
        // Arrange
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(10))
        buffer.writeNullTerminatedString("SCRAM-SHA-256")
        buffer.writeNullTerminatedString("")

        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        if case .sasl(let mechanisms) = auth?.kind {
            XCTAssertEqual(mechanisms, ["SCRAM-SHA-256"])
        } else {
            XCTFail("Expected .sasl, got \(String(describing: auth?.kind))")
        }
    }

    func testInitSASLEmptyMechanismList() {
        // Arrange — immediate empty string, so mechanisms list is empty
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(10))
        buffer.writeNullTerminatedString("")

        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        if case .sasl(let mechanisms) = auth?.kind {
            XCTAssertEqual(mechanisms, [])
        } else {
            XCTFail("Expected .sasl, got \(String(describing: auth?.kind))")
        }
    }

    // MARK: .saslContinue (rawValue == 11)

    func testInitSASLContinue() {
        // Arrange
        let data: [UInt8] = Array("r=serverNonce,s=salt,i=4096".utf8)
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(11))
        buffer.writeBytes(data)

        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        if case .saslContinue(let parsedData) = auth?.kind {
            XCTAssertEqual(parsedData, data)
        } else {
            XCTFail("Expected .saslContinue, got \(String(describing: auth?.kind))")
        }
    }

    func testInitSASLContinueEmptyData() {
        // Arrange — rawValue 11 but no payload; still valid (empty data)
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(11))

        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        if case .saslContinue(let parsedData) = auth?.kind {
            XCTAssertEqual(parsedData, [])
        } else {
            XCTFail("Expected .saslContinue, got \(String(describing: auth?.kind))")
        }
    }

    // MARK: .saslFinal (rawValue == 12)

    func testInitSASLFinal() {
        // Arrange
        let data: [UInt8] = Array("v=serverSignatureBase64".utf8)
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(12))
        buffer.writeBytes(data)

        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        if case .saslFinal(let parsedData) = auth?.kind {
            XCTAssertEqual(parsedData, data)
        } else {
            XCTFail("Expected .saslFinal, got \(String(describing: auth?.kind))")
        }
    }

    func testInitSASLFinalEmptyData() {
        // Arrange
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(12))

        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        if case .saslFinal(let parsedData) = auth?.kind {
            XCTAssertEqual(parsedData, [])
        } else {
            XCTFail("Expected .saslFinal, got \(String(describing: auth?.kind))")
        }
    }

    // MARK: .unsupported (all other rawValues)

    func testInitUnsupportedKerberosV5() {
        // rawValue == 2 → KerberosV5 — should be wrapped in .unsupported
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(2))

        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        if case .unsupported(let rawValue) = auth?.kind {
            XCTAssertEqual(rawValue, 2)
        } else {
            XCTFail("Expected .unsupported(2), got \(String(describing: auth?.kind))")
        }
    }

    func testInitUnsupportedUnknownFutureMethod() {
        // rawValue == 99 — unknown future method
        var buffer = ByteBuffer()
        buffer.writeInteger(Int32(99))

        var auth: Message.Authentication?
        XCTAssertNoThrow(auth = try Message.Authentication(buffer: &buffer))

        if case .unsupported(let rawValue) = auth?.kind {
            XCTAssertEqual(rawValue, 99)
        } else {
            XCTFail("Expected .unsupported(99), got \(String(describing: auth?.kind))")
        }
    }

    // MARK: Missing data

    func testInitEmptyBuffer() {
        // Arrange — completely empty buffer: can't read the rawValue Int32
        var buffer = ByteBuffer()

        XCTAssertThrowsError(try Message.Authentication(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.cantParseAuthenticationMethod).localizedDescription
            )
        }
    }
}
