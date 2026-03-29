extension Message {
    struct SimpleQuery: MessageType {
        let identifier: Identifier = .frontend(.simpleQuery)
        var string: String

        init(_ string: String) {
            self.string = string
        }

        func encode(into buffer: inout ByteBuffer) {
            buffer.writeNullTerminatedString(string)
        }
    }
}
