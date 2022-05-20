@testable import PostgreSQL
import XCTest

final class MessageReadyForQueryTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Message.ReadyForQuery(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? ClientError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(.cantParseReadyForQueryTransactionStatus).localizedDescription
            )
        }

        // Arrange
        let status: Message.ReadyForQuery.Status = .idle
        buffer = ByteBuffer()
        buffer.writeInteger(status.rawValue)

        // Act
        let messageType = try! Message.ReadyForQuery(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .readyForQuery)
        XCTAssertEqual(messageType.status, status)
    }

    func testStatuses() {
        // Assert
        XCTAssertEqual(Message.ReadyForQuery.Status.idle.rawValue, 0x49)
        XCTAssertEqual(Message.ReadyForQuery.Status.transaction.rawValue, 0x54)
        XCTAssertEqual(Message.ReadyForQuery.Status.transactionFailed.rawValue, 0x45)
    }
}
