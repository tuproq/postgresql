extension Message {
    struct Describe: MessageType {
        let identifier: Identifier = .describe
        let command: Command
        let name: String

        init(command: Command, name: String = "") {
            self.command = command
            self.name = name
        }

        func encode(into buffer: inout ByteBuffer) {
            buffer.writeInteger(command.rawValue)
            buffer.writeNullTerminatedString(name)
        }
    }
}
