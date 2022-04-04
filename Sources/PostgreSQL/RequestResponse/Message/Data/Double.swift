import NIOCore

extension Double: Codable {
    public static var psqlType: DataType { .float8 }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .float4):
            guard buffer.readableBytes == 4, let float = buffer.readFloat() else {
                throw error(.invalidData(format: format, type: type))
            }
            self = Double(float)
        case (.binary, .float8):
            guard buffer.readableBytes == 8, let double = buffer.readDouble() else {
                throw error(.invalidData(format: format, type: type))
            }
            self = double
        case (.text, .float4), (.text, .float8):
            guard let string = buffer.readString(), let value = Double(string) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = value
        default: throw error(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, with format: DataFormat) {
        switch format {
        case .binary: buffer.writeDouble(self)
        case .text: buffer.writeString(String(self))
        }
    }
}
