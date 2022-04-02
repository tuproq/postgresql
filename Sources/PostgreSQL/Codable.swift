import NIOCore

public typealias Codable = Decodable & Encodable

public protocol Decodable {
    init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws
}

extension Decodable {
    public init(buffer: inout ByteBuffer, type: DataType) throws {
        try self.init(buffer: &buffer, format: .binary, type: type)
    }
}

public protocol Encodable {
    static var psqlFormat: DataFormat { get }
    static var psqlType: DataType { get }

    func encode(into buffer: inout ByteBuffer, with format: DataFormat)
}

extension Encodable {
    public static var psqlFormat: DataFormat { .binary }

    public func encode(into buffer: inout ByteBuffer) {
        encode(into: &buffer, with: Self.psqlFormat)
    }
}
