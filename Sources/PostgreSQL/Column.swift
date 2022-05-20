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
        guard let name = buffer.readNullTerminatedString() else { throw clientError(.invalidColumnName) }
        guard let tableID = buffer.readInteger(as: Int32.self) else { throw clientError(.invalidColumnTableID) }
        guard let attributeNumber = buffer.readInteger(as: Int16.self) else {
            throw clientError(.invalidColumnAttributeNumber)
        }
        guard let dataTypeID = buffer.readInteger(as: DataType.self) else { throw clientError(.invalidColumnDataTypeID) }
        guard let dataTypeSize = buffer.readInteger(as: Int16.self) else { throw clientError(.invalidColumnDataTypeSize) }
        guard let attributeTypeModifier = buffer.readInteger(as: Int32.self) else {
            throw clientError(.invalidColumnAttributeTypeModifier)
        }
        guard let dataFormat = buffer.readInteger(as: DataFormat.self) else { throw clientError(.invalidColumnDataFormat) }
        self.name = name
        self.tableID = tableID
        self.attributeNumber = attributeNumber
        self.dataTypeID = dataTypeID
        self.dataTypeSize = dataTypeSize
        self.attributeTypeModifier = attributeTypeModifier
        self.dataFormat = dataFormat
    }
}
