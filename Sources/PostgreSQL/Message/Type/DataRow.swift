extension Message {
    struct DataRow: MessageType {
        let identifier: Identifier = .dataRow
        let values: [ByteBuffer?]

        init(buffer: inout ByteBuffer) throws {
            guard let values = buffer.readArray(as: ByteBuffer?.self, { buffer in
                buffer.readBytes()
            }) else {
                throw postgreSQLError(.cantParseDataRowValues)
            }
            self.values = values
        }
    }
}
