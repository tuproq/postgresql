extension Message {
    struct Authentication: MessageType {
        let identifier: Identifier = .authentication
        let kind: Kind

        enum Kind: Int32 {
            case ok = 0
            case kerberosV5 = 2
            case cleartext = 3
            case md5 = 5
            case scmCredential = 6
            case gss = 7
            case gssContinue = 8
            case sspi = 9
            case sasl = 10
            case saslContinue = 11
            case saslFinal = 12
        }

        init(buffer: inout ByteBuffer) throws {
            guard let rawValue = buffer.readInteger(as: Int32.self), let kind = Kind(rawValue: rawValue) else {
                throw clientError(.cantParseAuthenticationMethod)
            }
            self.kind = kind
        }
    }
}
