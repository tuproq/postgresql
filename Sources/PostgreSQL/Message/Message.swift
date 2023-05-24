import NIOCore

struct Message: CustomStringConvertible, Equatable {
    var identifier: Identifier
    var buffer: ByteBuffer
    var description: String { "Identifier: \(identifier), Buffer: \(buffer)" }
}
