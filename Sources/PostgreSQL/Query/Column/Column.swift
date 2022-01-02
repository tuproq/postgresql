import NIOCore

struct Column: CustomStringConvertible {
    var name: String
    var tableID: Int32
    var attributeNumber: Int16
    var dataType: DataType
    var dataTypeSize: Int16
    var attributeTypeModifier: Int32
    var formatCode: FormatCode

    var description: String {
        """
        name: \(name)
        tableID: \(tableID)
        attributeNumber: \(attributeNumber)
        dataType: \(dataType)
        dataTypeSize: \(dataTypeSize)
        attributeTypeModifier: \(attributeTypeModifier)
        formatCode: \(formatCode)
        """
    }

    init(buffer: inout ByteBuffer) throws {
        guard let name = buffer.readNullTerminatedString() else {
            throw MessageError("An invalid column `name`.")
        }
        guard let tableID = buffer.readInteger(as: Int32.self) else {
            throw MessageError("An invalid column `tableID`.")
        }
        guard let attributeNumber = buffer.readInteger(as: Int16.self) else {
            throw MessageError("An invalid column `attributeNumber`.")
        }
        guard let dataType = buffer.readInteger(as: DataType.self) else {
            throw MessageError("An invalid column `dataTypeID`.")
        }
        guard let dataTypeSize = buffer.readInteger(as: Int16.self) else {
            throw MessageError("An invalid column `dataTypeSize`.")
        }
        guard let attributeTypeModifier = buffer.readInteger(as: Int32.self) else {
            throw MessageError("An invalid column `attributeTypeModifier`.")
        }
        guard let formatCode = buffer.readInteger(as: FormatCode.self) else {
            throw MessageError("An invalid column `formatCode`.")
        }

        self.name = name
        self.tableID = tableID
        self.attributeNumber = attributeNumber
        self.dataType = dataType
        self.dataTypeSize = dataTypeSize
        self.attributeTypeModifier = attributeTypeModifier
        self.formatCode = formatCode
    }
}
