import NIOCore

extension Message {
    struct BackendKeyData: MessageType {
        let identifier: Identifier = .backendKeyData
        let processID: Int32
        let secretKey: Int32
    }
}
