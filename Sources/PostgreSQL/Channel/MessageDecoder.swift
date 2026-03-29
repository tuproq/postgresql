import NIOCore

final class MessageDecoder: ByteToMessageDecoder {
    typealias InboundOut = Message
    let connection: PostgreSQL
    var isFirstMessage = true

    init(connection: PostgreSQL) {
        self.connection = connection
    }

    func decode(
        context: ChannelHandlerContext,
        buffer: inout ByteBuffer
    ) throws -> DecodingState {
        var currentBuffer = buffer
        guard let rawByte = currentBuffer.readInteger(as: UInt8.self) else { return .needMoreData }
        let backendIdentifier = Message.BackendIdentifier(rawByte)
        let messageIdentifier = Message.Identifier.backend(backendIdentifier)
        let message: Message

        if isFirstMessage &&
            connection.configuration.requiresTLS &&
            (backendIdentifier == .sslSupported || backendIdentifier == .sslUnsupported) {
            message = Message(
                identifier: messageIdentifier,
                type: .backend,
                buffer: context.channel.allocator.buffer(capacity: 0)
            )
        } else {
            guard let messageSize = currentBuffer
                .readInteger(as: Int32.self)
                .flatMap(Int.init) else { return .needMoreData }
            guard messageSize >= 4 else {
                throw postgreSQLError(
                    .invalidData(
                        format: .binary,
                        type: .null
                    )
                )
            }
            guard let messageBuffer = currentBuffer.readSlice(length: messageSize - 4) else { return .needMoreData }
            message = Message(
                identifier: messageIdentifier,
                type: .backend,
                buffer: messageBuffer
            )
        }

        isFirstMessage = false
        buffer = currentBuffer
        context.fireChannelRead(wrapInboundOut(message))

        return .continue
    }

    func decodeLast(
        context: ChannelHandlerContext,
        buffer: inout ByteBuffer,
        seenEOF: Bool
    ) throws -> DecodingState {
        .needMoreData
    }
}
