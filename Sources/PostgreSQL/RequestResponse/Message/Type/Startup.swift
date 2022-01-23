import NIOCore

extension Message {
    struct Startup: MessageType {
        let identifier: Identifier = .startup
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
            buffer.writeString("user\0\(user)\0")
            buffer.writeString("database\0\(database)\0")
            buffer.writeString("replication\0\(replication.rawValue)\0")
            buffer.writeString("\0")
        }
    }
}
