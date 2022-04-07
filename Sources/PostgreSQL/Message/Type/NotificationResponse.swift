extension Message {
    struct NotificationResponse: MessageType {
        let identifier: Identifier = .notificationResponse
        let processID: Int32
        let channel: String
        let payload: String

        init(buffer: inout ByteBuffer) throws {
            guard let processID: Int32 = buffer.readInteger() else {
                throw MessageError("Can't parse process ID.")
            }
            guard let channel = buffer.readNullTerminatedString() else {
                throw MessageError("Can't parse channel.")
            }
            guard let payload = buffer.readNullTerminatedString() else {
                throw MessageError("Can't parse payload.")
            }
            self.processID = processID
            self.channel = channel
            self.payload = payload
        }
    }
}
