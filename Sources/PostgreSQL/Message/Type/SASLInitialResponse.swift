extension Message {
    /// SASLInitialResponse (F)
    ///
    /// Wire format (payload written by `encode`; the 'p' identifier byte and
    /// the Int32 total-length prefix are added by `MessageEncoder`):
    ///
    ///   String   – SASL mechanism name, null-terminated
    ///   Int32    – byte length of the initial client response (-1 if absent)
    ///   Byten    – initial client response (not null-terminated)
    struct SASLInitialResponse: MessageType {
        let identifier: Identifier = .saslInitialResponse
        let mechanism: String
        let initialResponse: [UInt8]

        init(
            mechanism: String,
            initialResponse: [UInt8]
        ) {
            self.mechanism = mechanism
            self.initialResponse = initialResponse
        }

        func encode(into buffer: inout ByteBuffer) {
            buffer.writeNullTerminatedString(mechanism)
            buffer.writeInteger(Int32(initialResponse.count))
            buffer.writeBytes(initialResponse)
        }
    }
}
