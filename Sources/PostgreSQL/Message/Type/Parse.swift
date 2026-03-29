extension Message {
    struct Parse: MessageType {
        let identifier: Identifier = .frontend(.parse)
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
            precondition(
                parameterTypes.count <= Int16.max,
                """
                Parameter count \(parameterTypes.count) exceeds the maximum Int16 value allowed by the PostgreSQL
                protocol (\(Int16.max)).
                """
            )
            buffer.writeInteger(Int16(parameterTypes.count))

            for parameterType in parameterTypes {
                buffer.writeInteger(parameterType.rawValue)
            }
        }
    }
}
