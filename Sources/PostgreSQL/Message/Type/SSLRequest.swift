extension Message {
    struct SSLRequest: MessageType {
        let identifier: Identifier = .none
        var code: Int32 = 80877103

        func encode(into buffer: inout ByteBuffer) {
            buffer.writeInteger(code)
        }
    }
}
