import NIOCore

extension Message {
    struct RowDescription: MessageType, Equatable {
        let identifier: Identifier = .rowDescription
        let columns: [Column]

        init(buffer: inout ByteBuffer) throws {
            guard let columns = try buffer.readArray(as: Column.self, { buffer in
                try .init(buffer: &buffer)
            }) else {
                throw MessageError("Can't parse row description columns.")
            }
            self.columns = columns
        }
    }
}
