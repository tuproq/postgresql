extension UInt8: PostgreSQLCodable {
    public static var psqlType: DataType { .char }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch type {
        case .bpchar, .char:
            guard buffer.readableBytes == 1, let value = buffer.readInteger(as: Self.self) else {
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
        if type == .bpchar || type == .char {
            buffer.writeInteger(self)
        } else {
            throw postgreSQLError(.invalidDataType(type))
        }
    }
}
