extension Message {
    struct NotificationResponse: MessageType {
        let identifier: Identifier = .notificationResponse
        let processID: Int32
        let channel: String
        let payload: String

        init(buffer: inout ByteBuffer) throws {
            guard let processID: Int32 = buffer.readInteger() else {
                throw clientError(.cantParseNotificationProcessID)
            }
            guard let channel = buffer.readNullTerminatedString() else {
                throw clientError(.cantParseNotificationChannel(processID: processID))
            }
            guard let payload = buffer.readNullTerminatedString() else {
                throw clientError(.cantParseNotificationPayload(processID: processID, channel: channel))
            }
            self.processID = processID
            self.channel = channel
            self.payload = payload
        }
    }
}
