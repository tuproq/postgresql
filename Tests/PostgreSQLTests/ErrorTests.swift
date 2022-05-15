@testable import PostgreSQL
import XCTest

final class MessageErrorTests: BaseTests {
    func testInit() {
        // Arrange
        let message = "An unknown error."

        // Act
        let error = MessageError(message)

        // Assert
        XCTAssertEqual(error.errorDescription, message)
    }
}

final class ErrorTypeTests: BaseTests {
    func testCases() {
        // Arrange
        let dataFormat: DataFormat = .binary
        let dataTypeID: DataType = .bool

        // Assert
        XCTAssertEqual(
            ErrorType.invalidData(format: dataFormat, type: dataTypeID).message,
            "An invalid data for data format `\(dataFormat)` and data type `\(dataTypeID)`."
        )
        XCTAssertEqual(
            ErrorType.invalidData(format: dataFormat, type: dataTypeID).message,
            ErrorType.invalidData(format: dataFormat, type: dataTypeID).description
        )

        XCTAssertEqual(ErrorType.invalidDataType(dataTypeID).message, "An invalid data type `\(dataTypeID)`.")
        XCTAssertEqual(
            ErrorType.invalidDataType(dataTypeID).message,
            ErrorType.invalidDataType(dataTypeID).description
        )

        XCTAssertEqual(ErrorType.unknown.message, "An unknown error.")
        XCTAssertEqual(ErrorType.unknown.message, ErrorType.unknown.description)
    }
}
