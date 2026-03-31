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
            throw postgreSQLError(.decoding(type: elementType)) // A binary format support only
        }

        // PostgreSQL binary array header: ndim (Int32), flags (Int32), element OID (Int32).
        // flags is a has-null-elements indicator: 0 = no nulls, 1 = has nulls.
        // It is NOT a format code — comparing it to format.rawValue was wrong and
        // caused every real PostgreSQL array (flags=0, no nulls) to fail to decode.
        guard let (isNotEmpty, flags, elementTypeValue) = buffer.readMultipleIntegers(
            as: (Int32, Int32, Int32).self
        ),
              isNotEmpty >= 0,
              isNotEmpty <= 1,
              flags == 0 || flags == 1
        else {
            throw postgreSQLError(.decoding(type: elementType))
        }

        // Arrays with null elements cannot be decoded into [Element] where Element
        // is non-optional.  The element-level guard (elementLength >= 0) below would
        // also catch this, but an early check here produces a clearer error.
        if flags == 1 {
            throw postgreSQLError(.decoding(type: elementType))
        }

        guard isNotEmpty == 1 else {
            self = .init()
            return
        }

        guard let elementDataType = DataType(rawValue: elementTypeValue) else {
            throw postgreSQLError(.decoding(type: elementType))
        }

        // Each dimension is described by a (size, lbound) pair.  PostgreSQL arrays
        // are 1-based by default (lbound = 1) but can be declared with any lower
        // bound (e.g. '[0:2]={1,2,3}'::int4[]).  We only support 1-dimensional arrays
        // (ndim == 1, enforced above), so we read exactly one (size, lbound) pair.
        // lbound is stored for completeness but not validated — restricting to lbound==1
        // would silently reject valid non-default-lower-bound arrays.
        guard let (elementsCount, _lbound) = buffer.readMultipleIntegers(as: (Int32, Int32).self),
              elementsCount > 0
        else {
            throw postgreSQLError(.decoding(type: elementType))
        }
        _ = _lbound  // lower bound accepted but unused; only 1D access by index is exposed

        var result = Array<Element>()
        result.reserveCapacity(Int(elementsCount))

        for _ in 0..<elementsCount {
            guard let elementLength = buffer.readInteger(as: Int32.self), elementLength >= 0 else {
                throw postgreSQLError(.decoding(type: elementType))
            }

            guard var elementBuffer = buffer.readSlice(length: numericCast(elementLength)) else {
                throw postgreSQLError(.decoding(type: elementType))
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
        let elementType = String(describing: Element.Type.self)

        guard case .binary = format else {
            throw postgreSQLError(.encoding(type: elementType)) // binary format only
        }

        let isNotEmpty: Int32 = !isEmpty ? 1 : 0
        let elementDataType = Element.psqlType
        buffer.writeInteger(isNotEmpty)
        buffer.writeInteger(Int32(0)) // flags: 0 = no null elements (not a format code)
        buffer.writeInteger(elementDataType.rawValue)

        guard !isEmpty else { return }

        let size = Int32(count)
        let lbound: Int32 = 1 // lower bound: 1-based (PostgreSQL default)
        buffer.writeInteger(size)
        buffer.writeInteger(lbound)

        for element in self {
            try element.encodeRaw(into: &buffer, format: format, type: elementDataType)
        }
    }
}
