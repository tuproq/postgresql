import Foundation
import NIOCore

extension ByteBuffer {
    mutating func readArray<T>(as type: T.Type, _ handler: (inout ByteBuffer) throws -> (T)) rethrows -> [T]? {
        guard let count: Int = readInteger(as: Int16.self).flatMap(numericCast) else { return nil }
        var array = [T]()
        array.reserveCapacity(count)
        for _ in 0..<count { try array.append(handler(&self)) }

        return array
    }

    mutating func writeArray<T>(_ array: [T], handler: (inout ByteBuffer, T) -> ()) {
        writeInteger(numericCast(array.count), as: Int16.self)
        for element in array { handler(&self, element) }
    }

    mutating func writeArray<T>(_ array: [T]) where T: FixedWidthInteger {
        writeArray(array) { buffer, element in buffer.writeInteger(element) }
    }

    mutating func writeArray<T>(_ array: [T]) where T: RawRepresentable, T.RawValue: FixedWidthInteger {
        writeArray(array) { buffer, element in buffer.writeInteger(element.rawValue) }
    }
}

extension ByteBuffer {
    mutating func readBytes() -> ByteBuffer? {
        guard let count: Int = readInteger(as: Int32.self).flatMap(numericCast) else { return nil }
        return readSlice(length: count)
    }
}

extension ByteBuffer {
    mutating func readDouble() -> Double? {
        readInteger(as: UInt64.self).map { Double(bitPattern: $0) }
    }

    mutating func writeDouble(_ double: Double) {
        writeInteger(double.bitPattern)
    }
}

extension ByteBuffer {
    mutating func readFloat() -> Float? {
        readInteger(as: UInt32.self).map { Float(bitPattern: $0) }
    }

    mutating func writeFloat(_ float: Float) {
        writeInteger(float.bitPattern)
    }
}

extension ByteBuffer {
    mutating func readInteger<T>(
        endianness: Endianness = .big,
        as rawRepresentable: T.Type
    ) -> T? where T: RawRepresentable, T.RawValue: FixedWidthInteger {
        guard let rawValue = readInteger(endianness: endianness, as: T.RawValue.self) else { return nil }
        return T(rawValue: rawValue)
    }
}

extension ByteBuffer {
    mutating func readNullTerminatedString() -> String? {
        if let nullIndex = readableBytesView.firstIndex(of: 0) {
            defer { moveReaderIndex(forwardBy: 1) }
            return readString(length: nullIndex - readerIndex)
        }

        return nil
    }

    mutating func readString() -> String? {
        readString(length: readableBytes)
    }
}

extension ByteBuffer {
    func getUUID(at index: Int) -> UUID? {
        var uuid: uuid_t = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        return viewBytes(at: index, length: MemoryLayout.size(ofValue: uuid)).map { bufferBytes in
            withUnsafeMutableBytes(of: &uuid) { target in
                precondition(target.count <= bufferBytes.count)
                target.copyBytes(from: bufferBytes)
            }
            return UUID(uuid: uuid)
        }
    }

    mutating func readUUID() -> UUID? {
        guard readableBytes >= MemoryLayout<UUID>.size,
              let value: UUID = getUUID(at: readerIndex) else { return nil }
        moveReaderIndex(forwardBy: MemoryLayout<UUID>.size)

        return value
    }
}
