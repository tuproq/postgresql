extension Message {
    struct ParameterDescription: MessageType {
        let identifier: Identifier = .parameterDescription
        let dataTypeIDs: [DataType]

        init(buffer: inout ByteBuffer) throws {
            guard let dataTypeIDs = try buffer.readArray(as: DataType.self, { buffer in
                guard let dataTypeID = buffer.readInteger(as: DataType.self) else {
                    throw postgreSQLError(.cantParseParameterDataType)
                }
                return dataTypeID
            }) else {
                throw postgreSQLError(.cantParseParameterDataTypes)
            }
            self.dataTypeIDs = dataTypeIDs
        }
    }
}
