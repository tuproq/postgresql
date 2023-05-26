extension Message {
    struct ParameterStatus: MessageType {
        let identifier: Identifier = .parameterStatus
        var name: String
        var value: String

        init(buffer: inout ByteBuffer) throws {
            guard let name = buffer.readNullTerminatedString() else {
                throw postgreSQLError(.cantParseParameterStatusName)
            }
            guard let value = buffer.readNullTerminatedString() else {
                throw postgreSQLError(.cantParseParameterStatusValue(name: name))
            }
            self.name = name
            self.value = value
        }
    }
}
