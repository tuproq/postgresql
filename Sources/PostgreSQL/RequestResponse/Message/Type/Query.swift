import NIOCore

extension Message {
    struct Query: MessageType {
        let identifier: Identifier = .query
        var string: String

        init(_ string: String) {
            self.string = string
        }

        func write(into buffer: inout ByteBuffer) {
            buffer.writeNullTerminatedString(string)
        }
    }
}
