import Foundation

extension Array: PostgreSQLCodable where Element: PostgreSQLCodable {
    public static var psqlType: DataType {
        let elementType = Element.Type.self

        if elementType == Bool.Type.self {
            return .boolArray
        } else if elementType == Data.Type.self {
            return .byteaArray
        } else if elementType == Double.Type.self {
            return .float8Array
        } else if elementType == Float.Type.self {
            return .float4Array
        } else if elementType == Int.Type.self {
            return MemoryLayout<Int>.size == 8 ? .int8Array : .int4Array
        } else if elementType == Int16.Type.self {
            return .int2Array
        } else if elementType == Int32.Type.self {
            return .int4Array
        } else if elementType == Int64.Type.self {
            return .int8Array
        } else if elementType == String.Type.self {
            return .textArray
        } else if elementType == UInt8.Type.self {
            return .charArray
        } else if elementType == UUID.Type.self {
            return .uuidArray
        }

        preconditionFailure("The `\(elementType)` is not supported.")
    }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        let elementType = String(describing: Element.Type.self)

        guard case .binary = format else {
            throw clientError(.decoding(type: elementType)) // A binary format support only
        }

        guard let (isNotEmpty, elementFormatValue, elementTypeValue) = buffer.readMultipleIntegers(
            as: (Int32, Int32, Int32).self
        ),
              isNotEmpty >= 0,
              isNotEmpty <= 1,
              elementFormatValue == format.rawValue
        else {
            throw clientError(.decoding(type: elementType))
        }

        guard isNotEmpty == 1 else {
            self = []
            return
        }

        guard let elementDataType = DataType(rawValue: elementTypeValue) else {
            throw clientError(.decoding(type: elementType))
        }

        guard let (elementsCount, dimensions) = buffer.readMultipleIntegers(as: (Int32, Int32).self),
              elementsCount > 0,
              dimensions == 1
        else {
            throw clientError(.decoding(type: elementType))
        }

        var result = Array<Element>()
        result.reserveCapacity(Int(elementsCount))

        for _ in 0..<elementsCount {
            guard let elementLength = buffer.readInteger(as: Int32.self), elementLength >= 0 else {
                throw clientError(.decoding(type: elementType))
            }

            guard var elementBuffer = buffer.readSlice(length: numericCast(elementLength)) else {
                throw clientError(.decoding(type: elementType))
            }

            let element = try Element(buffer: &elementBuffer, format: format, type: elementDataType)
            result.append(element)
        }

        self = result
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        let isNotEmpty: Int32 = !isEmpty ? 1 : 0
        let format = DataFormat.binary // A binary format support only
        let type = Element.psqlType
        buffer.writeInteger(isNotEmpty)
        buffer.writeInteger(Int32(format.rawValue))
        buffer.writeInteger(type.rawValue)

        guard !isEmpty else { return }

        let size: Int32 = numericCast(count)
        let dimensions: Int32 = 1 // 1 dimensional array support only
        buffer.writeInteger(size)
        buffer.writeInteger(dimensions)

        for element in self {
            try element.encodeRaw(into: &buffer, format: format, type: type)
        }
    }
}
