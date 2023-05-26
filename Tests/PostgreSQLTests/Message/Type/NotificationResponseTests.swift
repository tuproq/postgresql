@testable import PostgreSQL
import XCTest

final class MessageNotificationResponseTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Message.NotificationResponse(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(.cantParseNotificationProcessID).localizedDescription
            )
        }

        // Arrange
        let processID: Int32 = 1
        buffer = ByteBuffer()
        buffer.writeInteger(processID)

        // Act/Assert
        XCTAssertThrowsError(try Message.NotificationResponse(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(.cantParseNotificationChannel(processID: processID)).localizedDescription
            )
        }

        // Arrange
        let channel = "channel"
        buffer = ByteBuffer()
        buffer.writeInteger(processID)
        buffer.writeNullTerminatedString(channel)

        // Act/Assert
        XCTAssertThrowsError(try Message.NotificationResponse(buffer: &buffer)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                clientError(
                    .cantParseNotificationPayload(processID: processID, channel: channel)
                ).localizedDescription
            )
        }

        // Arrange
        let payload = "payload"
        buffer = ByteBuffer()
        buffer.writeInteger(processID)
        buffer.writeNullTerminatedString(channel)
        buffer.writeNullTerminatedString(payload)

        // Act
        let messageType = try! Message.NotificationResponse(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .notificationResponse)
        XCTAssertEqual(messageType.processID, processID)
        XCTAssertEqual(messageType.channel, channel)
        XCTAssertEqual(messageType.payload, payload)
    }
}
