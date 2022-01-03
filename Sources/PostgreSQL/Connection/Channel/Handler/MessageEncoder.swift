import NIOCore

final class MessageEncoder: MessageToByteEncoder {
    typealias OutboundIn = Message

    func encode(data: Message, out: inout ByteBuffer) throws {
        var message = data

        switch message.identifier {
        case .none: break
        default: if let value = message.identifier.value { out.writeInteger(value) }
        }

        let writerIndex = out.writerIndex
        out.moveWriterIndex(forwardBy: 4)
        out.writeBuffer(&message.buffer)
        out.setInteger(Int32(out.writerIndex - writerIndex), at: writerIndex)
    }
}
