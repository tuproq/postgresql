extension Bool: PostgreSQLCodable {
    public static var psqlType: DataType { .bool }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        guard type == .bool else { throw postgreSQLError(.invalidDataType(type)) }
        guard buffer.readableBytes == 1 else { throw postgreSQLError(.invalidData(format: format, type: type)) }

        switch format {
        case .binary:
            switch buffer.readInteger(as: UInt8.self) {
            case .some(0): self = false
            case .some(1): self = true
            default: throw postgreSQLError(.invalidData(format: format, type: type))
            }
        case .text:
            switch buffer.readInteger(as: UInt8.self) {
            case .some(UInt8(ascii: "f")): self = false
            case .some(UInt8(ascii: "t")): self = true
            default: throw postgreSQLError(.invalidData(format: format, type: type))
            }
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        if type == .bool {
            switch format {
            case .binary: buffer.writeInteger(UInt8(self ? 1 : 0))
            case .text: buffer.writeInteger(UInt8(ascii: self ? "t" : "f"))
            }
        } else {
            throw postgreSQLError(.invalidDataType(type))
        }
    }
}
