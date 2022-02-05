import NIOCore
@testable import PostgreSQL
import XCTest

final class MessageCommandCompleteTests: XCTestCase {
    func testInit() {
        // Arrange
        let bufferAllocator = ByteBufferAllocator()
        var buffer = bufferAllocator.buffer(capacity: 0)

        // Act/Assert
        XCTAssertThrowsError(try Message.CommandComplete(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse command tag.")
        }

        // Arrange
        let command = "SELECT"
        buffer = bufferAllocator.buffer(capacity: 0)
        buffer.writeNullTerminatedString(command)

        // Act
        let messageType = try! Message.CommandComplete(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .commandComplete)
        XCTAssertEqual(messageType.command, command)
    }
}
