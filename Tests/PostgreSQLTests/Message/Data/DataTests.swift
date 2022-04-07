@testable import PostgreSQL
import XCTest

final class DataTests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(Data.psqlFormat, .binary)
        XCTAssertEqual(Data.psqlType, .bytea)
    }

    func testInit() {
        // Arrange
        let format: DataFormat = .binary
        let value = Data("text".utf8)
        var expectedValue: Data?
        var buffer = ByteBuffer()
        value.encode(into: &buffer, format: format)

        // Act/Assert
        XCTAssertNoThrow(expectedValue = try Data(buffer: &buffer, format: format))
        XCTAssertEqual(expectedValue, value)
    }
}
