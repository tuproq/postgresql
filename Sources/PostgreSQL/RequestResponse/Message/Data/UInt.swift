import NIOCore

extension UInt8: Codable {
    public static var psqlType: DataType { .char }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch type {
        case .bpchar, .char:
            guard buffer.readableBytes == 1, let value = buffer.readInteger(as: Self.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = value
        default: throw error(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) {
        buffer.writeInteger(self, as: Self.self)
    }
}
