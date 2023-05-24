extension Message {
    struct Close: MessageType {
        let identifier: Identifier = .close
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
