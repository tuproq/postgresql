import NIOCore

extension Message {
    struct Startup: MessageType {
        let identifier: Identifier = .none
        var protocolVersion: Int32
        var user: String
        var database: String
        var replication: Replication

        enum Replication: String {
            case `true`
            case `false`
            case database
        }

        init(
            protocolVersion: Int32 = 0x00_03_00_00,
            user: String,
            database: String? = nil,
            replication: Replication = .false
        ) {
            self.protocolVersion = protocolVersion
            self.user = user
            self.database = database ?? user
            self.replication = replication
        }

        func write(into buffer: inout ByteBuffer) {
            buffer.writeInteger(protocolVersion)
            buffer.writeNullTerminatedString("user")
            buffer.writeNullTerminatedString(user)
            buffer.writeNullTerminatedString("database")
            buffer.writeNullTerminatedString(database)
            buffer.writeNullTerminatedString("replication")
            buffer.writeNullTerminatedString(replication.rawValue)
            buffer.writeString("\0")
        }
    }
}
