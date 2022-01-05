@testable import PostgreSQL
import XCTest

final class ConnectionOptionTests: XCTestCase {
    let identifier = "com.custom.identifier"
    let host = "localhost"
    let port = 1234
    let username = "username"
    let password = "password"
    let database = "database"
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
        XCTAssertEqual(option.numberOfThreads, 1)

        // Act
        option = Connection.Option(
            identifier: identifier,
            host: host,
            port: port,
            username: username,
            password: password,
            database: database,
            numberOfThreads: numberOfThreads
        )

        // Assert
        XCTAssertEqual(option.identifier, identifier)
        XCTAssertEqual(option.host, host)
        XCTAssertEqual(option.port, port)
        XCTAssertEqual(option.username, username)
        XCTAssertEqual(option.password, password)
        XCTAssertEqual(option.database, database)
        XCTAssertEqual(option.numberOfThreads, numberOfThreads)
    }
}
