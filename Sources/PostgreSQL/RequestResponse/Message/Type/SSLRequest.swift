import NIOCore

extension Message {
    struct SSLRequest: MessageType {
        let identifier: Identifier = .none
        var code: Int32 = 80877103

        func write(into buffer: inout ByteBuffer) {
            buffer.writeInteger(code)
        }
    }
}
