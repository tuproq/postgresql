extension Float: PostgreSQLCodable {
    public static var psqlType: DataType { .float4 }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .float4):
            guard buffer.readableBytes == 4, let float = buffer.readFloat() else {
                throw clientError(.invalidData(format: format, type: type))
            }
            self = float
        case (.binary, .float8):
            guard buffer.readableBytes == 8, let double = buffer.readDouble() else {
                throw clientError(.invalidData(format: format, type: type))
            }
            self = Self(double)
        case (.text, .float4), (.text, .float8):
            guard let string = buffer.readString(), let value = Self(string) else {
                throw clientError(.invalidData(format: format, type: type))
            }
            self = value
        default: throw clientError(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        if type == .float4 || type == .float8 {
            switch format {
            case .binary: buffer.writeFloat(self)
            case .text: buffer.writeString(String(self))
            }
        } else {
            throw clientError(.invalidDataType(type))
        }
    }
}
