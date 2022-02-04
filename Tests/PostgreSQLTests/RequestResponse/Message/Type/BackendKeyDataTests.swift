import NIOCore
@testable import PostgreSQL
import XCTest

final class MessageBackendKeyDataTests: XCTestCase {
    func testInit() {
        // Arrange
        let bufferAllocator = ByteBufferAllocator()
        var buffer = bufferAllocator.buffer(capacity: 0)

        // Act/Assert
        XCTAssertThrowsError(try Message.BackendKeyData(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse backend key data processID.")
        }

        // Arrange
        let processID: Int32 = 1
        buffer = bufferAllocator.buffer(capacity: 0)
        buffer.writeInteger(processID)

        // Act/Assert
        XCTAssertThrowsError(try Message.BackendKeyData(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse backend key data secretKey for \(processID).")
        }

        // Arrange
        let secretKey: Int32 = 2
        buffer = bufferAllocator.buffer(capacity: 0)
        buffer.writeInteger(processID)
        buffer.writeInteger(secretKey)

        // Act
        let messageType = try! Message.BackendKeyData(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .backendKeyData)
        XCTAssertEqual(messageType.processID, processID)
        XCTAssertEqual(messageType.secretKey, secretKey)
        XCTAssertEqual(messageType.description, "\(processID):\(secretKey)")
    }
}