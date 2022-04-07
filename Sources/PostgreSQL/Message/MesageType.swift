protocol MessageType {
    var identifier: Message.Identifier { get }

    func encode(into buffer: inout ByteBuffer)
}

extension MessageType {
    func encode(into buffer: inout ByteBuffer) {}
}
