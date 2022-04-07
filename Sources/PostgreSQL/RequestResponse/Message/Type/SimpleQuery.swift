extension Message {
    struct SimpleQuery: MessageType {
        let identifier: Identifier = .simpleQuery
        var string: String

        init(_ string: String) {
            self.string = string
        }

        func write(into buffer: inout ByteBuffer) {
            buffer.writeNullTerminatedString(string)
        }
    }
}
