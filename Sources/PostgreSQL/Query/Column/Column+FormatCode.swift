extension Column {
    enum FormatCode: Int16, CustomStringConvertible {
        case text
        case binary

        var description: String {
            switch self {
            case .text: return "text"
            case .binary: return "binary"
            }
        }
    }
}
