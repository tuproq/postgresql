@testable import PostgreSQL
import XCTest

final class PostgreSQLTests: BaseTests {
    func testInit() {
        // Arrange
        let configuration = PostgreSQL.Configuration()

        // Act
        let connection = PostgreSQL(configuration)

        // Assert
        XCTAssertEqual(connection.configuration, configuration)
        XCTAssertNotNil(connection.logger.label, configuration.identifier)
    }
}
