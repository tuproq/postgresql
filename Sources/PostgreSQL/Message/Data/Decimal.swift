import Foundation

extension Decimal: Codable {
    public static var psqlType: DataType { .numeric }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .numeric):
            guard let value = Numeric(buffer: &buffer) else { throw error(.invalidData(format: format, type: type)) }
            self = value.decimal
        case (.text, .numeric):
            guard let string = buffer.readString(), let value = Decimal(string: string) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = value
        default: throw error(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        let numeric = Numeric(decimal: self)
        buffer.writeInteger(numeric.ndigits)
        buffer.writeInteger(numeric.weight)
        buffer.writeInteger(numeric.sign)
        buffer.writeInteger(numeric.dscale)

        var value = numeric.value
        buffer.writeBuffer(&value)
    }
}
