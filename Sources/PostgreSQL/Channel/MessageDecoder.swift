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
        let message: Message

        // SSL negotiation produces a single-byte response ('S' = 0x53 supported,
        // 'N' = 0x4E unsupported) with no length field.  These bytes collide with
        // `parameterStatus` and `noticeResponse` in the normal message stream, so
        // we detect them by raw byte value *before* constructing a BackendIdentifier,
        // and map them to the synthetic non-colliding identifiers defined in
        // BackendIdentifier (0xFE / 0xFF).
        if isFirstMessage &&
            connection.configuration.requiresTLS &&
            (rawByte == 0x53 || rawByte == 0x4E) {
            let sslIdentifier: Message.BackendIdentifier = rawByte == 0x53 ? .sslSupported : .sslUnsupported
            message = Message(
                identifier: .backend(sslIdentifier),
                type: .backend,
                buffer: context.channel.allocator.buffer(capacity: 0)
            )
        } else {
            let backendIdentifier = Message.BackendIdentifier(rawByte)
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
                identifier: .backend(backendIdentifier),
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
