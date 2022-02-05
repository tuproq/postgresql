import NIOCore

extension Message {
    struct CommandComplete: MessageType {
        let identifier: Identifier = .commandComplete
        let command: String

        init(buffer: inout ByteBuffer) throws {
            guard let command = buffer.readNullTerminatedString() else {
                throw MessageError("Can't parse command tag.")
            }
            self.command = command
        }
    }
}
