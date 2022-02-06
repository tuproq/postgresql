@testable import PostgreSQL
import XCTest

final class ConnectionOptionTests: BaseTests {
    let identifier = "com.custom.identifier"
    let host = "localhost"
    let port = 1234
    let username = "username"
    let password = "password"
    let database = "database"
    let requiresTLS = true
    let numberOfThreads = 2

    func testInit() {
        // Act
        var option = Connection.Option()

        // Assert
        XCTAssertEqual(option.identifier, Connection.Option.defaultIdentifier)
        XCTAssertEqual(option.host, Connection.Option.defaultHost)
        XCTAssertEqual(option.port, Connection.Option.defaultPort)
        XCTAssertNil(option.username)
        XCTAssertNil(option.password)
        XCTAssertNil(option.database)
        XCTAssertFalse(option.requiresTLS)
        XCTAssertEqual(option.numberOfThreads, 1)

        // Act
        option = Connection.Option(
            identifier: identifier,
            host: host,
            port: port,
            username: username,
            password: password,
            database: database,
            requiresTLS: requiresTLS,
            numberOfThreads: numberOfThreads
        )

        // Assert
        XCTAssertEqual(option.identifier, identifier)
        XCTAssertEqual(option.host, host)
        XCTAssertEqual(option.port, port)
        XCTAssertEqual(option.username, username)
        XCTAssertEqual(option.password, password)
        XCTAssertEqual(option.database, database)
        XCTAssertEqual(option.requiresTLS, requiresTLS)
        XCTAssertEqual(option.numberOfThreads, numberOfThreads)
    }

    func testInitWithURL() {
        // Arrange
        var url = URL(string: "postgresql://")!

        // Act
        var option = Connection.Option(url: url)!

        // Assert
        XCTAssertEqual(option.identifier, Connection.Option.defaultIdentifier)
        XCTAssertEqual(option.host, Connection.Option.defaultHost)
        XCTAssertEqual(option.port, Connection.Option.defaultPort)
        XCTAssertNil(option.username)
        XCTAssertNil(option.password)
        XCTAssertNil(option.database)
        XCTAssertFalse(option.requiresTLS)
        XCTAssertEqual(option.numberOfThreads, 1)

        // Arrange
        url = URL(string: "postgresql://\(username):\(password)@\(host):\(port)/\(database)")!

        // Act
        option = Connection.Option(
            identifier: identifier,
            url: url,
            requiresTLS: requiresTLS,
            numberOfThreads: numberOfThreads
        )!

        // Assert
        XCTAssertEqual(option.identifier, identifier)
        XCTAssertEqual(option.host, host)
        XCTAssertEqual(option.port, port)
        XCTAssertEqual(option.username, username)
        XCTAssertEqual(option.password, password)
        XCTAssertEqual(option.database, database)
        XCTAssertEqual(option.requiresTLS, requiresTLS)
        XCTAssertEqual(option.numberOfThreads, numberOfThreads)

        // Arrange
        url = URL(string: "postgres://\(username):\(password)@\(host):\(port)/\(database)")!

        // Act
        option = Connection.Option(
            identifier: identifier,
            url: url,
            requiresTLS: requiresTLS,
            numberOfThreads: numberOfThreads
        )!

        // Assert
        XCTAssertEqual(option.identifier, identifier)
        XCTAssertEqual(option.host, host)
        XCTAssertEqual(option.port, port)
        XCTAssertEqual(option.username, username)
        XCTAssertEqual(option.password, password)
        XCTAssertEqual(option.database, database)
        XCTAssertEqual(option.requiresTLS, requiresTLS)
        XCTAssertEqual(option.numberOfThreads, numberOfThreads)

        // Arrange
        url = URL(string: "invalid://\(username):\(password)@\(host):\(port)/\(database)")!

        // Act/Assert
        XCTAssertNil(Connection.Option(url: url))
    }
}
