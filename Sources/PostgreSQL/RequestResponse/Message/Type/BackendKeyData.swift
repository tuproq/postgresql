extension Message {
    struct BackendKeyData: MessageType {
        let identifier: Identifier = .backendKeyData
        let processID: Int32
        let secretKey: Int32

        init(buffer: inout ByteBuffer) throws {
            guard let processID = buffer.readInteger(as: Int32.self) else {
                throw MessageError("Can't parse backend key data processID.")
            }
            guard let secretKey = buffer.readInteger(as: Int32.self) else {
                throw MessageError("Can't parse backend key data secretKey for \(processID).")
            }
            self.processID = processID
            self.secretKey = secretKey
        }
    }
}
