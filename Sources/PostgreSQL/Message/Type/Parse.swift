extension Message {
    struct Parse: MessageType {
        let identifier: Identifier = .parse
        let statementName: String
        let query: String
        let parameterTypes: [DataType]

        init(statementName: String = "", query: String, parameterTypes: [DataType] = .init()) {
            self.statementName = statementName
            self.query = query
            self.parameterTypes = parameterTypes
        }

        func encode(into buffer: inout ByteBuffer) {
            buffer.writeNullTerminatedString(statementName)
            buffer.writeNullTerminatedString(query)
            buffer.writeInteger(Int16(parameterTypes.count))

            for parameterType in parameterTypes {
                buffer.writeInteger(parameterType.rawValue)
            }
        }
    }
}
