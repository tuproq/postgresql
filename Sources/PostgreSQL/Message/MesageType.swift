protocol MessageType: CustomStringConvertible {
    var identifier: Message.Identifier { get }

    func encode(into buffer: inout ByteBuffer)
}

extension MessageType {
    var description: String { "\(identifier)" }

    func encode(into buffer: inout ByteBuffer) {}
}
