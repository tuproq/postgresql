import Foundation
import NIOFoundationCompat

extension Data: PostgreSQLCodable {
    public static var psqlType: DataType { .bytea }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        guard type == .bytea else { throw postgreSQLError(.invalidDataType(type)) }

        switch format {
        case .binary:
            self = buffer.readData(length: buffer.readableBytes, byteTransferStrategy: .automatic) ?? .init()
        case .text:
            guard let hexString = buffer.readString() else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            guard hexString.hasPrefix("\\x") else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            let hex = hexString.dropFirst(2)
            guard hex.count % 2 == 0 else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            var bytes = [UInt8]()
            bytes.reserveCapacity(hex.count / 2)
            var index = hex.startIndex
            while index < hex.endIndex {
                let nextIndex = hex.index(index, offsetBy: 2)
                guard let byte = UInt8(hex[index..<nextIndex], radix: 16) else {
                    throw postgreSQLError(.invalidData(format: format, type: type))
                }
                bytes.append(byte)
                index = nextIndex
            }
            self = Data(bytes)
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        guard type == .bytea else { throw postgreSQLError(.invalidDataType(type)) }

        switch format {
        case .binary:
            buffer.writeBytes(self)
        case .text:
            let hex = self.map { String(format: "%02x", $0) }.joined()
            buffer.writeString("\\x\(hex)")
        }
    }
}
