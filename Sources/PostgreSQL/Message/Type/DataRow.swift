extension Message {
    struct DataRow: MessageType {
        let identifier: Identifier = .backend(.dataRow)
        let values: [ByteBuffer?]

        init(buffer: inout ByteBuffer) throws {
            guard let values = try buffer.readArray(as: ByteBuffer?.self, { buffer in
                buffer.readBytes()
            }) else {
                throw postgreSQLError(.cantParseDataRowValues)
            }
            self.values = values
        }
    }
}
