import Foundation
import NIOCore

extension String: Codable {
    public static var psqlType: DataType { .text }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch type {
        case .name, .text, .varchar:
            guard let string = buffer.readString() else { throw error(.invalidData(format: format, type: type)) }
            self = string
        case .uuid:
            guard let uuid = try? UUID(buffer: &buffer, format: format, type: type) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = uuid.uuidString
        default: throw error(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, with format: DataFormat) {
        buffer.writeString(self)
    }
}

extension String {
    var droppingLeadingSlash: String { first == "/" ? String(dropFirst()) : self }
}
