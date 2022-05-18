extension Array: Codable where Element: Codable {
    public static var psqlType: DataType {
//        switch type(of: Element.self) {
//
//        }

        let elementType = Element.Type.self

        if elementType == Bool.Type.self {
            return .boolArray
        } else if elementType == Int32.Type.self {
            return .int4Array
        }

        preconditionFailure("Error here...")
    }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
//        guard type == .bool else { throw error(.invalidDataType(type)) }
//        guard buffer.readableBytes == 1 else { throw error(.invalidData(format: format, type: type)) }
//
//        switch format {
//        case .binary:
//            switch buffer.readInteger(as: UInt8.self) {
//            case .some(0): self = false
//            case .some(1): self = true
//            default: throw error(.invalidData(format: format, type: type))
//            }
//        case .text:
//            switch buffer.readInteger(as: UInt8.self) {
//            case .some(UInt8(ascii: "f")): self = false
//            case .some(UInt8(ascii: "t")): self = true
//            default: throw error(.invalidData(format: format, type: type))
//            }
//        }

        self = []
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        buffer.writeInteger(UInt32(isEmpty ? 0 : 1))
        buffer.writeInteger(Int32(0))
        buffer.writeInteger(Element.psqlType.rawValue)
        guard !isEmpty else { return }
        buffer.writeInteger(numericCast(count), as: Int32.self)
        buffer.writeInteger(Int32(1))

        try forEach { element in
            let lengthIndex = buffer.writerIndex
            buffer.writeInteger(Int32(0))
            let startIndex = buffer.writerIndex
            try element.encode(into: &buffer)
            buffer.setInteger(numericCast(buffer.writerIndex - startIndex), at: lengthIndex, as: Int32.self)
        }
    }
}
