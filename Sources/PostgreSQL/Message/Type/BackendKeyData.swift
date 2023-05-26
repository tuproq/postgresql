extension Message {
    struct BackendKeyData: MessageType {
        let identifier: Identifier = .backendKeyData
        let processID: Int32
        let secretKey: Int32

        init(buffer: inout ByteBuffer) throws {
            guard let processID = buffer.readInteger(as: Int32.self) else {
                throw postgreSQLError(.cantParseBackendKeyDataProcessID)
            }
            guard let secretKey = buffer.readInteger(as: Int32.self) else {
                throw postgreSQLError(.cantParseBackendKeyDataSecretKey(processID: processID))
            }
            self.processID = processID
            self.secretKey = secretKey
        }
    }
}
