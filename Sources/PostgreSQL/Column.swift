public struct Column: CustomStringConvertible, Hashable {
    public let name: String
    public let tableID: Int32
    public let attributeNumber: Int16
    public let dataTypeID: DataType
    public let dataTypeSize: Int16
    public let attributeTypeModifier: Int32
    public let dataFormat: DataFormat

    public var description: String {
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

    public init(buffer: inout ByteBuffer) throws {
        guard let name = buffer.readNullTerminatedString() else { throw postgreSQLError(.invalidColumnName) }
        guard let tableID = buffer.readInteger(as: Int32.self) else { throw postgreSQLError(.invalidColumnTableID) }
        guard let attributeNumber = buffer.readInteger(as: Int16.self) else {
            throw postgreSQLError(.invalidColumnAttributeNumber)
        }
        guard let dataTypeID = buffer.readInteger(as: DataType.self) else {
            throw postgreSQLError(.invalidColumnDataTypeID)
        }
        guard let dataTypeSize = buffer.readInteger(as: Int16.self) else {
            throw postgreSQLError(.invalidColumnDataTypeSize)
        }
        guard let attributeTypeModifier = buffer.readInteger(as: Int32.self) else {
            throw postgreSQLError(.invalidColumnAttributeTypeModifier)
        }
        guard let dataFormat = buffer.readInteger(as: DataFormat.self) else {
            throw postgreSQLError(.invalidColumnDataFormat)
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
