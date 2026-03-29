import Foundation

extension Decimal: PostgreSQLCodable {
    public static var psqlType: DataType { .numeric }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .numeric):
            guard let numeric = Numeric(buffer: &buffer),
                  let value = numeric.decimal else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = value
        case (.text, .numeric):
            guard let string = buffer.readString(),
                  let value = Decimal(
                    string: string,
                    locale: .init(identifier: "en_US_POSIX")
                  )
            else {
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
        switch (format, type) {
        case (.binary, .numeric):
            let numeric = Numeric(decimal: self)
            buffer.writeInteger(numeric.ndigits)
            buffer.writeInteger(numeric.weight)
            buffer.writeInteger(numeric.sign)
            buffer.writeInteger(numeric.dscale)

            for digit in numeric.digits {
                buffer.writeInteger(digit)
            }
        case (.text, .numeric): buffer.writeString(description)
        default: throw postgreSQLError(.invalidDataType(type))
        }
    }
}
