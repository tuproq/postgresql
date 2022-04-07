extension Message {
    struct Password: MessageType {
        let identifier: Identifier = .password
        var value: String

        init(_ value: String) {
            self.value = value
        }

        func encode(into buffer: inout ByteBuffer) {
            buffer.writeNullTerminatedString(value)
        }
    }
}
