import NIOCore

final class MessageEncoder: MessageToByteEncoder {
    typealias OutboundIn = Message

    func encode(data: Message, out: inout ByteBuffer) throws {
        var message = data
        if message.identifier != .none { out.writeInteger(message.identifier.value) }
        let writerIndex = out.writerIndex
        out.moveWriterIndex(forwardBy: 4)
        out.writeBuffer(&message.buffer)
        out.setInteger(Int32(out.writerIndex - writerIndex), at: writerIndex)
    }
}
