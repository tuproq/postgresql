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

final class ColumnErrorTypeTests: BaseTests {
    func testCases() {
        // Assert
        XCTAssertEqual(
            ErrorType.Column.invalidColumnAttributeNumber.rawValue,
            "An invalid column `attributeNumber`."
        )
        XCTAssertEqual(
            ErrorType.Column.invalidColumnAttributeNumber.rawValue,
            ErrorType.Column.invalidColumnAttributeNumber.description
        )

        XCTAssertEqual(
            ErrorType.Column.invalidColumnAttributeTypeModifier.rawValue,
            "An invalid column `attributeTypeModifier`."
        )
        XCTAssertEqual(
            ErrorType.Column.invalidColumnAttributeTypeModifier.rawValue,
            ErrorType.Column.invalidColumnAttributeTypeModifier.description
        )

        XCTAssertEqual(ErrorType.Column.invalidColumnDataFormat.rawValue, "An invalid column `dataFormat`.")
        XCTAssertEqual(
            ErrorType.Column.invalidColumnDataFormat.rawValue,
            ErrorType.Column.invalidColumnDataFormat.description
        )

        XCTAssertEqual(ErrorType.Column.invalidColumnDataTypeID.rawValue, "An invalid column `dataTypeID`.")
        XCTAssertEqual(
            ErrorType.Column.invalidColumnDataTypeID.rawValue,
            ErrorType.Column.invalidColumnDataTypeID.description
        )

        XCTAssertEqual(ErrorType.Column.invalidColumnDataTypeSize.rawValue, "An invalid column `dataTypeSize`.")
        XCTAssertEqual(
            ErrorType.Column.invalidColumnDataTypeSize.rawValue,
            ErrorType.Column.invalidColumnDataTypeSize.description
        )

        XCTAssertEqual(ErrorType.Column.invalidColumnName.rawValue, "An invalid column `name`.")
        XCTAssertEqual(
            ErrorType.Column.invalidColumnName.rawValue,
            ErrorType.Column.invalidColumnName.description
        )

        XCTAssertEqual(ErrorType.Column.invalidColumnTableID.rawValue, "An invalid column `tableID`.")
        XCTAssertEqual(
            ErrorType.Column.invalidColumnTableID.rawValue,
            ErrorType.Column.invalidColumnTableID.description
        )
    }
}
