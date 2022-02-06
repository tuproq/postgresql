@testable import PostgreSQL
import XCTest

final class MessageParameterStatusTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = bufferAllocator.buffer(capacity: 0)

        // Act/Assert
        XCTAssertThrowsError(try Message.ParameterStatus(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse parameter status name.")
        }

        // Arrange
        let name = "client_encoding"
        buffer = bufferAllocator.buffer(capacity: 0)
        buffer.writeNullTerminatedString(name)

        // Act/Assert
        XCTAssertThrowsError(try Message.ParameterStatus(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse parameter status value for \(name).")
        }

        // Arrange
        let value = "UTF8"
        buffer = bufferAllocator.buffer(capacity: 0)
        buffer.writeNullTerminatedString(name)
        buffer.writeNullTerminatedString(value)

        // Act
        let messageType = try! Message.ParameterStatus(buffer: &buffer)

        // Assert
        XCTAssertEqual(messageType.identifier, .parameterStatus)
        XCTAssertEqual(messageType.name, name)
        XCTAssertEqual(messageType.value, value)
        XCTAssertEqual(messageType.description, "\(name): \(value)")
    }
}
