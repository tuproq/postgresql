public enum DataFormat: Int16, CustomStringConvertible {
    case binary = 1
    case text = 0

    public var description: String {
        switch self {
        case .binary: return "binary"
        case .text: return "text"
        }
    }
}
