extension Message {
    struct ReadyForQuery: MessageType {
        let identifier: Identifier = .readyForQuery
        let status: Status

        init(buffer: inout ByteBuffer) throws {
            guard let value = buffer.readInteger(as: UInt8.self), let status = Status(rawValue: value) else {
                throw MessageError("Can't parse transaction status.")
            }
            self.status = status
        }
    }
}

extension Message.ReadyForQuery {
    enum Status: UInt8 {
        case idle = 0x49 // 'I'
        case transaction = 0x54 // 'T'
        case transactionFailed = 0x45 // 'E'
    }
}
