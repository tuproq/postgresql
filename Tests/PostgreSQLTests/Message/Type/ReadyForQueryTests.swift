@testable import PostgreSQL
import XCTest

final class MessageReadyForQueryTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Message.ReadyForQuery(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.cantParseReadyForQueryTransactionStatus).localizedDescription
            )
        }

        // Arrange
        let status: Message.ReadyForQuery.Status = .idle
        buffer = ByteBuffer()
        buffer.writeInteger(status.rawValue)

        // Act
        let messageType = try! Message.ReadyForQuery(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .backend(.readyForQuery))
        XCTAssertEqual(messageType.status, status)
    }

    func testInitAllStatuses() {
        // Arrange
        let statuses: [Message.ReadyForQuery.Status] = [.idle, .transaction, .transactionFailed]

        for status in statuses {
            var buffer = ByteBuffer()
            buffer.writeInteger(status.rawValue)

            // Act
            let messageType = try? Message.ReadyForQuery(buffer: &buffer)

            // Assert
            XCTAssertNotNil(messageType)
            XCTAssertEqual(messageType?.status, status)
            XCTAssertEqual(messageType?.identifier, .backend(.readyForQuery))
        }
    }

    func testInitWithInvalidStatus() {
        // Arrange — an unrecognised transaction status byte
        var buffer = ByteBuffer()
        buffer.writeInteger(UInt8(0xFF))  // not a valid status

        // Act/Assert
        XCTAssertThrowsError(try Message.ReadyForQuery(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.cantParseReadyForQueryTransactionStatus).localizedDescription
            )
        }
    }

    func testStatuses() {
        // Assert
        XCTAssertEqual(Message.ReadyForQuery.Status.idle.rawValue, 0x49)
        XCTAssertEqual(Message.ReadyForQuery.Status.transaction.rawValue, 0x54)
        XCTAssertEqual(Message.ReadyForQuery.Status.transactionFailed.rawValue, 0x45)
    }

    func testStatusDescription() {
        // Assert — each status description should contain the human-readable name
        XCTAssertTrue(Message.ReadyForQuery.Status.idle.description.contains("Idle"))
        XCTAssertTrue(Message.ReadyForQuery.Status.transaction.description.contains("Transaction"))
        XCTAssertTrue(Message.ReadyForQuery.Status.transactionFailed.description.contains("TransactionFailed"))

        // And the ASCII character corresponding to the raw byte value
        XCTAssertTrue(Message.ReadyForQuery.Status.idle.description.contains("I"))
        XCTAssertTrue(Message.ReadyForQuery.Status.transaction.description.contains("T"))
        XCTAssertTrue(Message.ReadyForQuery.Status.transactionFailed.description.contains("E"))
    }

    func testReadyForQueryDescription() {
        // Arrange
        let statuses: [Message.ReadyForQuery.Status] = [.idle, .transaction, .transactionFailed]

        for status in statuses {
            var buffer = ByteBuffer()
            buffer.writeInteger(status.rawValue)
            let rfq = try! Message.ReadyForQuery(buffer: &buffer)

            // Assert — description combines identifier and status
            XCTAssertFalse(rfq.description.isEmpty)
            XCTAssertTrue(rfq.description.contains(status.description))
        }
    }
}
