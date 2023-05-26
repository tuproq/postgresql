extension Message {
    struct CommandComplete: MessageType {
        let identifier: Identifier = .commandComplete
        let command: String

        init(buffer: inout ByteBuffer) throws {
            guard let command = buffer.readNullTerminatedString() else {
                throw postgreSQLError(.cantParseCommandTag)
            }
            self.command = command
        }
    }
}
