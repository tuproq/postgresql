@testable import PostgreSQL
import XCTest

final class MessageBackendKeyDataTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Message.BackendKeyData(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? ClientError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(.cantParseBackendKeyDataProcessID).localizedDescription
            )
        }

        // Arrange
        let processID: Int32 = 1
        buffer = ByteBuffer()
        buffer.writeInteger(processID)

        // Act/Assert
        XCTAssertThrowsError(try Message.BackendKeyData(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? ClientError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(.cantParseBackendKeyDataSecretKey(processID: processID)).localizedDescription
            )
        }

        // Arrange
        let secretKey: Int32 = 2
        buffer = ByteBuffer()
        buffer.writeInteger(processID)
        buffer.writeInteger(secretKey)

        // Act
        let messageType = try! Message.BackendKeyData(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .backendKeyData)
        XCTAssertEqual(messageType.processID, processID)
        XCTAssertEqual(messageType.secretKey, secretKey)
    }
}
