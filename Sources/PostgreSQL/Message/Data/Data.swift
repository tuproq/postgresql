import Foundation
import NIOFoundationCompat

extension Data: Codable {
    public static var psqlType: DataType { .bytea }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        self = buffer.readData(length: buffer.readableBytes, byteTransferStrategy: .automatic)!
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        if type == .bytea {
            buffer.writeBytes(self)
        } else {
            throw clientError(.invalidDataType(type))
        }
    }
}
