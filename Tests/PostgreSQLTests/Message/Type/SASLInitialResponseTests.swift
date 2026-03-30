@testable import PostgreSQL
import XCTest

final class SASLInitialResponseTests: BaseTests {
    // MARK: Init

    func testInit() {
        // Arrange
        let mechanism = "SCRAM-SHA-256"
        let initialResponse: [UInt8] = Array("n,,n=user,r=clientNonce".utf8)

        // Act
        let messageType = Message.SASLInitialResponse(
            mechanism: mechanism,
            initialResponse: initialResponse
        )

        // Assert
        XCTAssertEqual(messageType.identifier, .frontend(.saslInitialResponse))
        XCTAssertEqual(messageType.mechanism, mechanism)
        XCTAssertEqual(messageType.initialResponse, initialResponse)
    }

    func testInitEmptyResponse() {
        // Arrange — some SASL mechanisms allow an empty initial response
        let mechanism = "PLAIN"
        let initialResponse: [UInt8] = []

        // Act
        let messageType = Message.SASLInitialResponse(
            mechanism: mechanism,
            initialResponse: initialResponse
        )

        // Assert
        XCTAssertEqual(messageType.mechanism, mechanism)
        XCTAssertEqual(messageType.initialResponse, [])
    }

    // MARK: Encode

    func testEncode() {
        // Arrange
        let mechanism = "SCRAM-SHA-256"
        let initialResponse: [UInt8] = Array("n,,n=user,r=abc".utf8)
        let messageType = Message.SASLInitialResponse(
            mechanism: mechanism,
            initialResponse: initialResponse
        )

        // Build expected buffer manually
        var expectedBuffer = ByteBuffer()
        expectedBuffer.writeNullTerminatedString(mechanism)
        expectedBuffer.writeInteger(Int32(initialResponse.count))
        expectedBuffer.writeBytes(initialResponse)

        // Act
        var buffer = ByteBuffer()
        messageType.encode(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }

    func testEncodeEmptyInitialResponse() {
        // Arrange
        let mechanism = "SCRAM-SHA-256"
        let initialResponse: [UInt8] = []
        let messageType = Message.SASLInitialResponse(
            mechanism: mechanism,
            initialResponse: initialResponse
        )

        var expectedBuffer = ByteBuffer()
        expectedBuffer.writeNullTerminatedString(mechanism)
        expectedBuffer.writeInteger(Int32(0))  // length == 0
        // no bytes follow for an empty response

        // Act
        var buffer = ByteBuffer()
        messageType.encode(into: &buffer)

        // Assert
        XCTAssertEqual(buffer, expectedBuffer)
    }

    func testEncodeResponseLengthMatchesPayload() {
        // Arrange — verify the 4-byte Int32 length field matches the actual payload
        let mechanism = "SCRAM-SHA-256"
        let initialResponse: [UInt8] = Array("n,,n=alice,r=clientNonce123".utf8)
        let messageType = Message.SASLInitialResponse(
            mechanism: mechanism,
            initialResponse: initialResponse
        )

        var buffer = ByteBuffer()
        messageType.encode(into: &buffer)

        // Skip past the null-terminated mechanism name
        let mechanismBytes = mechanism.utf8.count + 1  // +1 for null terminator
        buffer.moveReaderIndex(forwardBy: mechanismBytes)

        // Read the 4-byte length
        let encodedLength = buffer.readInteger(as: Int32.self)

        // Assert
        XCTAssertEqual(encodedLength, Int32(initialResponse.count))
    }
}
