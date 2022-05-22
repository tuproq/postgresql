@testable import PostgreSQL
import XCTest

final class ClientErrorTests: BaseTests {
    func testInit() {
        // Act
        var error = ClientError()

        // Assert
        XCTAssertEqual(error.errorDescription, clientError(.unknown).errorDescription)

        // Arrange
        let message = "A custom error."

        // Act
        error = ClientError(message)

        // Assert
        XCTAssertEqual(error.errorDescription, "\(String(describing: ClientError.self)): \(message)")
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
            "An invalid data type `\(dataTypeID)` for data format `\(dataFormat)`."
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

final class MessageErrorTypeTests: BaseTests {
    func testCases() {
        // Arrange
        let processID: Int32 = 1
        let channel = "channel"
        let parameterName = "parameterName"

        // Assert
        XCTAssertEqual(
            ErrorType.Message.cantParseBackendKeyDataProcessID.message,
            "Can't parse BackendKeyData processID."
        )
        XCTAssertEqual(
            ErrorType.Message.cantParseBackendKeyDataProcessID.message,
            ErrorType.Message.cantParseBackendKeyDataProcessID.description
        )

        XCTAssertEqual(
            ErrorType.Message.cantParseBackendKeyDataSecretKey(processID: processID).message,
            "Can't parse BackendKeyData secretKey for processID `\(processID)`."
        )
        XCTAssertEqual(
            ErrorType.Message.cantParseBackendKeyDataSecretKey(processID: processID).message,
            ErrorType.Message.cantParseBackendKeyDataSecretKey(processID: processID).description
        )

        XCTAssertEqual(ErrorType.Message.cantParseCommandTag.message, "Can't parse CommandComplete tag.")
        XCTAssertEqual(
            ErrorType.Message.cantParseCommandTag.message,
            ErrorType.Message.cantParseCommandTag.description
        )

        XCTAssertEqual(ErrorType.Message.cantParseDataRowValues.message, "Can't parse DataRow values.")
        XCTAssertEqual(
            ErrorType.Message.cantParseDataRowValues.message,
            ErrorType.Message.cantParseDataRowValues.description
        )

        XCTAssertEqual(
            ErrorType.Message.cantParseNotificationChannel(processID: processID).message,
            "Can't parse NotificationResponse channel for processID `\(processID)`."
        )
        XCTAssertEqual(
            ErrorType.Message.cantParseNotificationChannel(processID: processID).message,
            ErrorType.Message.cantParseNotificationChannel(processID: processID).description
        )

        XCTAssertEqual(
            ErrorType.Message.cantParseNotificationPayload(processID: processID, channel: channel).message,
            "Can't parse NotificationResponse payload for processID `\(processID)` and channel `\(channel)`."
        )
        XCTAssertEqual(
            ErrorType.Message.cantParseNotificationPayload(processID: processID, channel: channel).message,
            ErrorType.Message.cantParseNotificationPayload(processID: processID, channel: channel).description
        )

        XCTAssertEqual(
            ErrorType.Message.cantParseNotificationProcessID.message,
            "Can't parse NotificationResponse processID."
        )
        XCTAssertEqual(
            ErrorType.Message.cantParseNotificationProcessID.message,
            ErrorType.Message.cantParseNotificationProcessID.description
        )

        XCTAssertEqual(
            ErrorType.Message.cantParseParameterDataType.message,
            "Can't parse ParameterDescription type."
        )
        XCTAssertEqual(
            ErrorType.Message.cantParseParameterDataType.message,
            ErrorType.Message.cantParseParameterDataType.description
        )

        XCTAssertEqual(
            ErrorType.Message.cantParseParameterDataTypes.message,
            "Can't parse ParameterDescription types."
        )
        XCTAssertEqual(
            ErrorType.Message.cantParseParameterDataTypes.message,
            ErrorType.Message.cantParseParameterDataTypes.description
        )

        XCTAssertEqual(ErrorType.Message.cantParseParameterStatusName.message, "Can't parse ParameterStatus name.")
        XCTAssertEqual(
            ErrorType.Message.cantParseParameterStatusName.message,
            ErrorType.Message.cantParseParameterStatusName.description
        )

        XCTAssertEqual(
            ErrorType.Message.cantParseParameterStatusValue(name: parameterName).message,
            "Can't parse ParameterStatus value for name `\(parameterName)`."
        )
        XCTAssertEqual(
            ErrorType.Message.cantParseParameterStatusValue(name: parameterName).message,
            ErrorType.Message.cantParseParameterStatusValue(name: parameterName).description
        )

        XCTAssertEqual(
            ErrorType.Message.cantParseReadyForQueryTransactionStatus.message,
            "Can't parse ReadyForQuery transactionStatus."
        )
        XCTAssertEqual(
            ErrorType.Message.cantParseReadyForQueryTransactionStatus.message,
            ErrorType.Message.cantParseReadyForQueryTransactionStatus.description
        )

        XCTAssertEqual(
            ErrorType.Message.cantParseRowDescriptionColumns.message,
            "Can't parse RowDescription columns."
        )
        XCTAssertEqual(
            ErrorType.Message.cantParseRowDescriptionColumns.message,
            ErrorType.Message.cantParseRowDescriptionColumns.description
        )
    }
}
