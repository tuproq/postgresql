extension Message {
    struct Describe: MessageType {
        let identifier: Identifier = .describe
        let command: Command
        let name: String

        init(command: Command, name: String = "") {
            self.command = command
            self.name = name
        }

        func write(into buffer: inout ByteBuffer) {
            buffer.writeInteger(command.rawValue)
            buffer.writeNullTerminatedString(name)
        }
    }
}

extension Message.Describe {
    enum Command: UInt8 {
        case portal = 0x50 // 'P'
        case statement = 0x53 // 'S'
    }
}