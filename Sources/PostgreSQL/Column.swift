import NIOCore

struct Column: CustomStringConvertible, Equatable {
    let name: String
    let tableID: Int32
    let attributeNumber: Int16
    let dataTypeID: DataType
    let dataTypeSize: Int16
    let attributeTypeModifier: Int32
    let dataFormat: DataFormat

    var description: String {
        """
        name: \(name), \
        tableID: \(tableID), \
        attributeNumber: \(attributeNumber), \
        dataTypeID: \(dataTypeID), \
        dataTypeSize: \(dataTypeSize), \
        attributeTypeModifier: \(attributeTypeModifier), \
        dataFormat: \(dataFormat)
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
        guard let dataTypeID = buffer.readInteger(as: DataType.self) else {
            throw MessageError("An invalid column `dataTypeID`.")
        }
        guard let dataTypeSize = buffer.readInteger(as: Int16.self) else {
            throw MessageError("An invalid column `dataTypeSize`.")
        }
        guard let attributeTypeModifier = buffer.readInteger(as: Int32.self) else {
            throw MessageError("An invalid column `attributeTypeModifier`.")
        }
        guard let dataFormat = buffer.readInteger(as: DataFormat.self) else {
            throw MessageError("An invalid column `dataFormat`.")
        }
        self.name = name
        self.tableID = tableID
        self.attributeNumber = attributeNumber
        self.dataTypeID = dataTypeID
        self.dataTypeSize = dataTypeSize
        self.attributeTypeModifier = attributeTypeModifier
        self.dataFormat = dataFormat
    }
}
