extension Sequence where Element == UInt8 {
    func hexdigest() -> String {
        reduce("") { $0 + String(format: "%02x", $1) }
    }
}
