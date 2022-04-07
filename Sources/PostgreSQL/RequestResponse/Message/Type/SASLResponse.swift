extension Message {
    struct SASLResponse: MessageType {
        let identifier: Identifier = .saslResponse
        let data: [UInt8]

        init(data: [UInt8] = .init()) {
            self.data = data
        }

        init(buffer: inout ByteBuffer) {
            self.data = buffer.readBytes(length: buffer.readableBytes) ?? .init()
        }

        func write(into buffer: inout ByteBuffer) {
            buffer.writeBytes(data)
        }
    }
}
