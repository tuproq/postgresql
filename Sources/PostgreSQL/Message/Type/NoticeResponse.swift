extension Message {
    struct NoticeResponse: MessageType {
        let identifier: Identifier = .noticeResponse
        var fields = [Field: String]()

        init(buffer: inout ByteBuffer) throws {
            while let value = buffer.readInteger(as: UInt8.self) {
                if value == 0 {
                    break
                }
                guard let field = Field(rawValue: value), let string = buffer.readNullTerminatedString() else {
                    throw postgreSQLError(.cantParseNoticeResponseFields)
                }
                fields[field] = string
            }
        }
    }
}
