import Foundation

extension String: PostgreSQLCodable {
    public static var psqlFormat: DataFormat { .text }
    public static var psqlType: DataType { .text }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch type {
        case .name, .text, .varchar:
            guard let string = buffer.readString()
            else { throw postgreSQLError(.invalidData(format: format, type: type)) }
            self = string
        case .uuid:
            guard let uuid = try? UUID(buffer: &buffer, format: format, type: type) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = uuid.uuidString
        default: throw postgreSQLError(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .uuid):
            guard let uuid = UUID(uuidString: self) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            try uuid.encode(into: &buffer, format: format, type: type)
        case (_, .name), (_, .text), (_, .varchar), (_, .uuid): buffer.writeString(self)
        default: throw postgreSQLError(.invalidDataType(type))
        }
    }
}

extension String {
    var droppingLeadingSlash: String { first == "/" ? Self(dropFirst()) : self }
}
