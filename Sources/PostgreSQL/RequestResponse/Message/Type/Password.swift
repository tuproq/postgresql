import NIOCore

extension Message {
    struct Password: MessageType {
        let identifier: Identifier = .password
        var value: String

        init(_ value: String) {
            self.value = value
        }

        func write(into buffer: inout ByteBuffer) {
            buffer.writeNullTerminatedString(value)
        }
    }
}
