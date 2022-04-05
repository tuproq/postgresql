import NIOCore

extension Int16: Codable {
    public static var psqlType: DataType { .int2 }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .int2):
            guard buffer.readableBytes == 2, let value = buffer.readInteger(as: Int16.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = value
        case (.text, .int2):
            guard let string = buffer.readString(), let value = Int16(string) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = value
        default: throw error(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, with format: DataFormat) {
        switch format {
        case .binary: buffer.writeInteger(self, as: Int16.self)
        case .text: buffer.writeString(String(self))
        }
    }
}
