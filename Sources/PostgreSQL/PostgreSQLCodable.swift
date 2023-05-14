public typealias PostgreSQLCodable = PostgreSQLDecodable & PostgreSQLEncodable

public protocol PostgreSQLDecodable: Decodable {
    init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws
}

extension PostgreSQLDecodable {
    public init(buffer: inout ByteBuffer, type: DataType) throws {
        try self.init(buffer: &buffer, format: .binary, type: type)
    }
}

public protocol PostgreSQLEncodable: Encodable {
    static var psqlFormat: DataFormat { get }
    static var psqlType: DataType { get }

    func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws
}

extension PostgreSQLEncodable {
    public static var psqlFormat: DataFormat { .binary }

    public func encode(into buffer: inout ByteBuffer) throws {
        try encode(into: &buffer, format: Self.psqlFormat, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat) throws {
        try encode(into: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, type: DataType) throws {
        try encode(into: &buffer, format: Self.psqlFormat, type: type)
    }

    public func encodeRaw(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        let lengthIndex = buffer.writerIndex
        buffer.writeInteger(Int32(0))
        let startIndex = buffer.writerIndex
        try encode(into: &buffer, format: format, type: type)
        buffer.setInteger(numericCast(buffer.writerIndex - startIndex), at: lengthIndex, as: Int32.self)
    }
}
