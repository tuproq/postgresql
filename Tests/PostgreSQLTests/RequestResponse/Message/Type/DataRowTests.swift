import NIOCore
@testable import PostgreSQL
import XCTest

final class MessageDataRowTests: BaseTests {
    func testInit() {
        // Arrange
        var buffer = bufferAllocator.buffer(capacity: 0)

        // Act/Assert
        XCTAssertThrowsError(try Message.DataRow(buffer: &buffer)) { error in
            XCTAssertEqual(error.localizedDescription, "Can't parse data row values.")
        }
    }
}
