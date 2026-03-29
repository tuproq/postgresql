extension Message {
    struct ErrorResponse: MessageType {
        let identifier: Identifier = .backend(.errorResponse)
        var fields = [Field: String]()

        init(buffer: inout ByteBuffer) throws {
            while let value = buffer.readInteger(as: UInt8.self) {
                if value == 0 {
                    break
                }
                guard let string = buffer.readNullTerminatedString() else {
                    throw postgreSQLError(.cantParseErrorResponseFields)
                }

                if let field = Field(rawValue: value) {
                    fields[field] = string
                }
            }
        }
    }
}
