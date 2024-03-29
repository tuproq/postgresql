extension Double: PostgreSQLCodable {
    public static var psqlType: DataType { .float8 }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .float4):
            guard buffer.readableBytes == 4, let float = buffer.readFloat() else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = Self(float)
        case (.binary, .float8):
            guard buffer.readableBytes == 8, let double = buffer.readDouble() else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = double
        case (.text, .float4), (.text, .float8):
            guard let string = buffer.readString(), let value = Self(string) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = value
        default: throw postgreSQLError(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        if type == .float4 || type == .float8 {
            switch format {
            case .binary: buffer.writeDouble(self)
            case .text: buffer.writeString(String(self))
            }
        } else {
            throw postgreSQLError(.invalidDataType(type))
        }
    }
}
