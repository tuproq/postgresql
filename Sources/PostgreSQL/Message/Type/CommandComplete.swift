extension Message {
    struct CommandComplete: MessageType {
        let identifier: Identifier = .commandComplete
        let command: String

        init(buffer: inout ByteBuffer) throws {
            guard let command = buffer.readNullTerminatedString() else {
                throw clientError(.cantParseCommandTag)
            }
            self.command = command
        }
    }
}
