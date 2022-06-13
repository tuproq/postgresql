import Foundation

extension UUID: Codable {
    public static var psqlType: DataType { .uuid }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch format {
        case .binary:
            switch type {
            case .uuid:
                guard let uuid = buffer.readUUID() else {
                    throw clientError(.invalidData(format: format, type: type))
                }
                self = uuid
            case .text, .varchar:
                guard buffer.readableBytes == 36,
                      let uuid = buffer.readString().flatMap({ Self(uuidString: $0) }) else {
                    throw clientError(.invalidData(format: format, type: type))
                }
                self = uuid
            default: throw clientError(.invalidDataType(type))
            }
        case .text:
            guard buffer.readableBytes == 36, let uuid = buffer.readString().flatMap({ Self(uuidString: $0) }) else {
                throw clientError(.invalidData(format: format, type: type))
            }
            self = uuid
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        if type == .uuid || type == .text || type == .varchar {
            switch format {
            case .binary:
                buffer.writeBytes([
                    uuid.0, uuid.1, uuid.2, uuid.3,
                    uuid.4, uuid.5, uuid.6, uuid.7,
                    uuid.8, uuid.9, uuid.10, uuid.11,
                    uuid.12, uuid.13, uuid.14, uuid.15
                ])
            case .text:
                buffer.writeString(uuidString)
            }
        } else {
            throw clientError(.invalidDataType(type))
        }
    }
}
