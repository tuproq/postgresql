extension Message {
    struct Sync: MessageType {
        let identifier: Identifier = .frontend(.sync)
    }
}
