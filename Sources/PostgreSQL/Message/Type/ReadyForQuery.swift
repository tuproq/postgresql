extension Message {
    struct ReadyForQuery: MessageType {
        let identifier: Identifier = .readyForQuery
        let status: Status
        var description: String { "\(identifier) \(status)" }

        init(buffer: inout ByteBuffer) throws {
            guard let value = buffer.readInteger(as: UInt8.self), let status = Status(rawValue: value) else {
                throw clientError(.cantParseReadyForQueryTransactionStatus)
            }
            self.status = status
        }
    }
}

extension Message.ReadyForQuery {
    enum Status: UInt8, CustomStringConvertible {
        case idle = 0x49 // 'I'
        case transaction = 0x54 // 'T'
        case transactionFailed = 0x45 // 'E'

        var description: String {
            let name: String

            switch self {
            case .idle: name = "Idle"
            case .transaction: name = "Transaction"
            case .transactionFailed: name = "TransactionFailed"
            }

            return "\(name) (\(String(Character(Unicode.Scalar(rawValue)))))"
        }
    }
}
