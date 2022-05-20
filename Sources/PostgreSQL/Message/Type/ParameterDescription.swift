extension Message {
    struct ParameterDescription: MessageType {
        let identifier: Identifier = .parameterDescription
        let dataTypeIDs: [DataType]

        init(buffer: inout ByteBuffer) throws {
            guard let dataTypeIDs = try buffer.readArray(as: DataType.self, { buffer in
                guard let dataTypeID = buffer.readInteger(as: DataType.self) else {
                    throw clientError(.cantParseParameterDataType)
                }
                return dataTypeID
            }) else {
                throw clientError(.cantParseParameterDataTypes)
            }
            self.dataTypeIDs = dataTypeIDs
        }
    }
}
