@testable import PostgreSQL
import XCTest

final class PostgreSQLConfigurationTests: BaseTests {
    let identifier = "com.custom.identifier"
    let host = "localhost"
    let port = 1234
    let username = "username"
    let password = "password"
    let database = "database"
    let requiresTLS = true

    func testInit() {
        // Act
        var configuration = PostgreSQL.Configuration()

        // Assert
        XCTAssertEqual(configuration.identifier, PostgreSQL.Configuration.defaultIdentifier)
        XCTAssertEqual(configuration.host, PostgreSQL.Configuration.defaultHost)
        XCTAssertEqual(configuration.port, PostgreSQL.Configuration.defaultPort)
        XCTAssertNil(configuration.username)
        XCTAssertNil(configuration.password)
        XCTAssertNil(configuration.database)
        XCTAssertFalse(configuration.requiresTLS)

        // Act
        configuration = PostgreSQL.Configuration(
            identifier: identifier,
            host: host,
            port: port,
            username: username,
            password: password,
            database: database,
            requiresTLS: requiresTLS
        )

        // Assert
        XCTAssertEqual(configuration.identifier, identifier)
        XCTAssertEqual(configuration.host, host)
        XCTAssertEqual(configuration.port, port)
        XCTAssertEqual(configuration.username, username)
        XCTAssertEqual(configuration.password, password)
        XCTAssertEqual(configuration.database, database)
        XCTAssertEqual(configuration.requiresTLS, requiresTLS)
    }

    func testInitWithURL() {
        // Arrange
        var url = URL(string: "postgresql://")!

        // Act
        var configuration = PostgreSQL.Configuration(url: url)!

        // Assert
        XCTAssertEqual(configuration.identifier, PostgreSQL.Configuration.defaultIdentifier)
        XCTAssertEqual(configuration.host, PostgreSQL.Configuration.defaultHost)
        XCTAssertEqual(configuration.port, PostgreSQL.Configuration.defaultPort)
        XCTAssertNil(configuration.username)
        XCTAssertNil(configuration.password)
        XCTAssertNil(configuration.database)
        XCTAssertFalse(configuration.requiresTLS)

        // Arrange
        url = URL(string: "postgresql://\(username):\(password)@\(host):\(port)/\(database)")!

        // Act
        configuration = PostgreSQL.Configuration(
            identifier: identifier,
            url: url,
            requiresTLS: requiresTLS
        )!

        // Assert
        XCTAssertEqual(configuration.identifier, identifier)
        XCTAssertEqual(configuration.host, host)
        XCTAssertEqual(configuration.port, port)
        XCTAssertEqual(configuration.username, username)
        XCTAssertEqual(configuration.password, password)
        XCTAssertEqual(configuration.database, database)
        XCTAssertEqual(configuration.requiresTLS, requiresTLS)

        // Arrange
        url = URL(string: "postgres://\(username):\(password)@\(host):\(port)/\(database)")!

        // Act
        configuration = PostgreSQL.Configuration(
            identifier: identifier,
            url: url,
            requiresTLS: requiresTLS
        )!

        // Assert
        XCTAssertEqual(configuration.identifier, identifier)
        XCTAssertEqual(configuration.host, host)
        XCTAssertEqual(configuration.port, port)
        XCTAssertEqual(configuration.username, username)
        XCTAssertEqual(configuration.password, password)
        XCTAssertEqual(configuration.database, database)
        XCTAssertEqual(configuration.requiresTLS, requiresTLS)

        // Arrange
        url = URL(string: "invalid://\(username):\(password)@\(host):\(port)/\(database)")!

        // Act/Assert
        XCTAssertNil(PostgreSQL.Configuration(url: url))
    }
}
