import Foundation
import NIOCore

extension UUID: Codable {
    public static var psqlType: DataType { .uuid }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch type {
        case .uuid:
            guard let uuid = buffer.readUUID() else { throw error(.invalidData(format: format, type: type)) }
            self = uuid
        case .text, .varchar:
            let count = 36
            guard buffer.readableBytes == count,
                  let uuid = buffer.readString(length: count).flatMap({ UUID(uuidString: $0) }) else {
                      throw error(.invalidData(format: format, type: type))
                  }
            self = uuid
        default: throw error(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, with format: DataFormat) {
        buffer.writeBytes([
            uuid.0, uuid.1, uuid.2, uuid.3,
            uuid.4, uuid.5, uuid.6, uuid.7,
            uuid.8, uuid.9, uuid.10, uuid.11,
            uuid.12, uuid.13, uuid.14, uuid.15
        ])
    }
}