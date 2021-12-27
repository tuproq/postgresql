import NIOCore

final class MessageDecoder: ByteToMessageDecoder {
    typealias InboundOut = Message

    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        var currentBuffer = buffer
        guard let messageIdentifier = currentBuffer
            .readInteger(as: UInt8.self)
            .map(Message.Identifier.init) else { return .needMoreData }
        guard let messageSize = currentBuffer
            .readInteger(as: Int32.self)
            .flatMap(Int.init) else { return .needMoreData }
        guard let messageBuffer = currentBuffer.readSlice(length: messageSize - 4) else { return .needMoreData }
        let message = Message(identifier: messageIdentifier, buffer: messageBuffer)
        buffer = currentBuffer
        context.fireChannelRead(wrapInboundOut(message))

        return .continue
    }

    func decodeLast(context: ChannelHandlerContext, buffer: inout ByteBuffer, seenEOF: Bool) throws -> DecodingState {
        .needMoreData
    }
}
