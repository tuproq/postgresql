protocol MessageType {
    var identifier: Message.Identifier { get }

    func write(into buffer: inout ByteBuffer)
}

extension MessageType {
    func write(into buffer: inout ByteBuffer) {}
}
