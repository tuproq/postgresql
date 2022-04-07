@testable import PostgreSQL
import XCTest

final class MessageNotificationResponseTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = ByteBuffer()

        // Act/Assert
        XCTAssertThrowsError(try Message.NotificationResponse(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse process ID.")
        }

        // Arrange
        let processID: Int32 = 1
        buffer = ByteBuffer()
        buffer.writeInteger(processID)

        // Act/Assert
        XCTAssertThrowsError(try Message.NotificationResponse(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse channel.")
        }

        // Arrange
        let channel = "channel"
        buffer = ByteBuffer()
        buffer.writeInteger(processID)
        buffer.writeNullTerminatedString(channel)

        // Act/Assert
        XCTAssertThrowsError(try Message.NotificationResponse(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse payload.")
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
