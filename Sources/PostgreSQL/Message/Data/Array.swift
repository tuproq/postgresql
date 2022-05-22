extension Array: Codable where Element: Codable {
    public static var psqlType: DataType {
        let elementType = Element.Type.self

        if elementType == Bool.Type.self {
            return .boolArray
        } else if elementType == Int32.Type.self {
            return .int4Array
        }

        preconditionFailure("Error here...")
    }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        fatalError("Not implemented")
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        fatalError("Not implemented")
    }
}
