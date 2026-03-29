extension Message {
    struct Terminate: MessageType {
        let identifier: Identifier = .frontend(.terminate)
    }
}
