extension Message {
    struct Execute: MessageType {
        let identifier: Identifier = .execute
        let portalName: String
        let maxRows: Int32

        init(portalName: String = "", maxRows: Int32 = 0) {
            self.portalName = portalName
            self.maxRows = maxRows
        }

        func write(into buffer: inout ByteBuffer) {
            buffer.writeNullTerminatedString(portalName)
            buffer.writeInteger(maxRows)
        }
    }
}
