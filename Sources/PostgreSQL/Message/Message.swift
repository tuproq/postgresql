import NIO

public struct Message: Equatable {
    public var identifier: Identifier
    public var buffer: ByteBuffer
}
