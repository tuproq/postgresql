import Foundation

extension String: PostgreSQLCodable {
    public static var psqlType: DataType { .text }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch type {
        case .name, .text, .varchar:
            guard let string = buffer.readString() else { throw clientError(.invalidData(format: format, type: type)) }
            self = string
        case .uuid:
            guard let uuid = try? UUID(buffer: &buffer, format: format, type: type) else {
                throw clientError(.invalidData(format: format, type: type))
            }
            self = uuid.uuidString
        default: throw clientError(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        if type == .name || type == .text || type == .varchar || type == .uuid {
            buffer.writeString(self)
        } else {
            throw clientError(.invalidDataType(type))
        }
    }
}

extension String {
    var droppingLeadingSlash: String { first == "/" ? Self(dropFirst()) : self }
}
