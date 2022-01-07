@testable import PostgreSQL
import XCTest

final class ConnectionTests: XCTestCase {
    func testInit() {
        // Arrange
        let option = Connection.Option()

        // Act
        let connection = Connection(option)

        // Assert
        XCTAssertEqual(connection.option, option)
        XCTAssertNotNil(connection.logger.label, option.identifier)
    }
}
