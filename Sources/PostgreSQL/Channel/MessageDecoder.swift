import NIOCore

final class MessageDecoder: ByteToMessageDecoder {
    typealias InboundOut = Message
    let connection: PostgreSQL
    var isFirstMessage = true

    init(connection: PostgreSQL) {
        self.connection = connection
    }

    func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        var currentBuffer = buffer
        guard let messageIdentifier = currentBuffer
            .readInteger(as: UInt8.self)
            .map(Message.Identifier.init) else { return .needMoreData }
        let message: Message

        if isFirstMessage &&
            connection.configuration.requiresTLS &&
            (messageIdentifier == .sslSupported || messageIdentifier == .sslUnsupported) {
            message = Message(
                identifier: messageIdentifier,
                source: .backend,
                buffer: context.channel.allocator.buffer(capacity: 0)
            )
        } else {
            guard let messageSize = currentBuffer
                .readInteger(as: Int32.self)
                .flatMap(Int.init) else { return .needMoreData }
            guard let messageBuffer = currentBuffer.readSlice(length: messageSize - 4) else { return .needMoreData }
            message = Message(identifier: messageIdentifier, source: .backend, buffer: messageBuffer)
        }

        isFirstMessage = false
        buffer = currentBuffer
        context.fireChannelRead(wrapInboundOut(message))

        return .continue
    }

    func decodeLast(context: ChannelHandlerContext, buffer: inout ByteBuffer, seenEOF: Bool) throws -> DecodingState {
        .needMoreData
    }
}
