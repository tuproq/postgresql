@testable import PostgreSQL
import XCTest

final class StringTests: BaseTests {
    func testDefaultFormatAndType() {
        // Assert
        XCTAssertEqual(String.psqlFormat, .binary)
        XCTAssertEqual(String.psqlType, .text)
    }

    func testInitWithInvalidType() {
        // Arrange
        let type: DataType = .bool
        let value = "text"
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer)

        // Act/Assert
        XCTAssertThrowsError(try String(buffer: &buffer, type: type)) { error in
            XCTAssertNotNil(error as? PostgreSQLError)
            XCTAssertEqual(
                error.localizedDescription,
                postgreSQLError(.invalidDataType(type)).localizedDescription
            )
        }
    }

    func testInitWithValidValues() {
        // Arrange
        let value = UUID()
        var expectedValue: String?
        var buffer = ByteBuffer()
        try? value.encode(into: &buffer)

        // Act/Assert
        XCTAssertNoThrow(expectedValue = try String(buffer: &buffer, type: .uuid))
        XCTAssertEqual(expectedValue, value.uuidString)

        for format in DataFormat.allCases {
            // Arrange
            let value = "text"
            var expectedValue: String?
            var buffer = ByteBuffer()
            try? value.encode(into: &buffer, format: format)

            // Act/Assert
            XCTAssertNoThrow(expectedValue = try String(buffer: &buffer, format: format))
            XCTAssertEqual(expectedValue, value)
        }
    }

    func testInitWithInvalidValues() {
        // Arrange
        let invalidValues: [DataType: PostgreSQLCodable] = [
            .uuid: "text"
        ]

        for format in DataFormat.allCases {
            for (type, invalidValue) in invalidValues {
                var buffer = ByteBuffer()
                try? invalidValue.encode(into: &buffer, format: format)

                // Act/Assert
                XCTAssertThrowsError(try String(buffer: &buffer, format: format, type: type)) { error in
                    XCTAssertNotNil(error as? PostgreSQLError)
                    XCTAssertEqual(
                        error.localizedDescription,
                        postgreSQLError(.invalidData(format: format, type: type)).localizedDescription
                    )
                }
            }
        }
    }

    func testDroppingLeadingSlash() {
        // Arrange
        let rootPath = "/"
        let path = "path/to/folder"

        // Act/Assert
        XCTAssertEqual(rootPath.droppingLeadingSlash, "")
        XCTAssertEqual(path.droppingLeadingSlash, path)
    }
}
