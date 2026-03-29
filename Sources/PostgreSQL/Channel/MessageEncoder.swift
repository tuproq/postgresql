import NIOCore

final class MessageEncoder: MessageToByteEncoder {
    typealias OutboundIn = Message

    func encode(data: Message, out: inout ByteBuffer) throws {
        var message = data

        // SSLRequest and StartupMessage have no type byte — they are identified
        // solely by their length prefix, so we skip writing the identifier byte.
        if message.identifier != .frontend(.sslRequest) && message.identifier != .frontend(.startupMessage) {
            out.writeInteger(message.identifier.value)
        }

        let writerIndex = out.writerIndex
        out.moveWriterIndex(forwardBy: 4)
        out.writeBuffer(&message.buffer)
        out.setInteger(Int32(out.writerIndex - writerIndex), at: writerIndex)
    }
}
