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

        func write(into buffer: inout ByteBuffer) {
            buffer.writeNullTerminatedString(statementName)
            buffer.writeNullTerminatedString(query)
            buffer.writeInteger(numericCast(parameterTypes.count), as: Int16.self)
            for parameterType in parameterTypes { buffer.writeInteger(parameterType.rawValue) }
        }
    }
}
