import Foundation

struct Numeric {
    static let chunkSize = 4
    static let negativeSign: Int16 = 0x4000
    static let zero = "0"

    var ndigits: Int16
    var weight: Int16
    var sign: Int16
    var dscale: Int16
    var digits: [Int16]

    var decimal: Decimal? { .init(string: string, locale: .init(identifier: "en_US_POSIX")) }

    var string: String {
        guard ndigits > 0 else { return Self.zero }
        var integer = ""
        var fraction = ""

        for offset in 0..<ndigits {
            let character = digits[Int(offset)]
            let characterString = character.description

            if weight - offset >= 0 {
                if offset == 0 {
                    integer += characterString
                } else {
                    integer += String(repeating: Self.zero, count: Self.chunkSize - characterString.count) + characterString
                }
            } else {
                fraction += String(repeating: Self.zero, count: Self.chunkSize - characterString.count) + characterString
            }
        }

        let offset: Int16

        if weight > 0 {
            offset = weight + 1 - ndigits
        } else {
            offset = abs(weight) - ndigits
        }

        if offset > 0 {
            for _ in 0..<offset {
                if weight > 0 {
                    integer = integer + String(repeating: Self.zero, count: Self.chunkSize)
                } else {
                    fraction = String(repeating: Self.zero, count: Self.chunkSize) + fraction
                }
            }
        }

        if integer.isEmpty {
            integer = Self.zero
        }

        if fraction.count > dscale {
            let lastSignificant = fraction.index(fraction.startIndex, offsetBy: Int(dscale))
            fraction = String(fraction[..<lastSignificant])
        }

        let numeric = fraction.isEmpty ? integer : "\(integer).\(fraction)"

        return (sign & Self.negativeSign) == 0 ? numeric : "-\(numeric)"
    }

    init?(buffer: inout ByteBuffer) {
        guard let ndigits = buffer.readInteger(as: Int16.self),
              let weight = buffer.readInteger(as: Int16.self),
              let sign = buffer.readInteger(as: Int16.self),
              let dscale = buffer.readInteger(as: Int16.self) else { return nil }

        // A negative ndigits is a malformed server response — reject it rather
        // than creating an invalid CountableRange (0..<n where n<0 traps in debug).
        guard ndigits >= 0 else { return nil }

        self.ndigits = ndigits
        self.weight = weight
        self.sign = sign
        self.dscale = dscale

        var decodedDigits = [Int16]()
        decodedDigits.reserveCapacity(Int(ndigits))

        for _ in 0..<ndigits {
            guard let digit = buffer.readInteger(as: Int16.self) else { return nil }
            decodedDigits.append(digit)
        }

        digits = decodedDigits
    }

    init(decimal: Decimal) {
        let string = decimal.description.replacingOccurrences(
            of: ",",
            with: "."
        )
        self.init(string: string)
    }

    private init(string: String) {
        let parts = string.split(separator: ".")
        var integer: Substring
        let fraction: Substring?

        switch parts.count {
        case 1:
            integer = parts[0]
            fraction = nil
        case 2:
            integer = parts[0]
            fraction = parts[1]
        default: preconditionFailure("The type must be a valid decimal string.")
        }

        let isNegative: Bool

        if integer.hasPrefix("-") {
            integer = integer.dropFirst()
            isNegative = true
        } else {
            isNegative = false
        }

        var encodedDigits = [Int16]()
        var weight = -1

        for chunk in integer.chunkFromEnd(by: Self.chunkSize) {
            weight += 1
            encodedDigits.append(Int16(chunk) ?? 0)
        }

        var dscale = 0

        if let fraction = fraction {
            for chunk in fraction.chunkFromStart(by: Self.chunkSize) {
                dscale += chunk.count
                let paddedChunk = chunk + String(repeating: Self.zero, count: Self.chunkSize - chunk.count)
                encodedDigits.append(Int16(paddedChunk) ?? 0)
            }
        }

        // Foundation.Decimal is limited to 38 significant digits, so these
        // conversions are safe in practice.  The checked forms are used here
        // to make the failure mode explicit should this code ever be called
        // with values outside the Decimal range (e.g. from a raw string path).
        precondition(
            encodedDigits.count <= Int16.max,
            "Numeric digit count \(encodedDigits.count) exceeds Int16.max — value too large for PostgreSQL NUMERIC"
        )
        ndigits = Int16(encodedDigits.count)
        precondition(
            weight >= Int16.min && weight <= Int16.max,
            "Numeric weight \(weight) overflows Int16"
        )
        self.weight = Int16(weight)
        sign = isNegative ? Self.negativeSign : 0
        precondition(
            dscale >= 0 && dscale <= Int16.max,
            "Numeric dscale \(dscale) overflows Int16"
        )
        self.dscale = Int16(dscale)
        digits = encodedDigits
    }
}

private extension Collection {
    func chunkFromStart(by size: Int) -> [SubSequence] {
        if count <= size {
            return [self[startIndex..<endIndex]]
        }

        let offset = count % size
        var offsetIndex = startIndex
        var chunks = [SubSequence]()

        for _ in stride(from: 0, to: count - offset, by: size) {
            let endIndex = index(offsetIndex, offsetBy: size)
            chunks.append(self[offsetIndex..<endIndex])
            offsetIndex = endIndex
        }

        chunks.append(self[offsetIndex..<endIndex])

        return chunks
    }

    func chunkFromEnd(by size: Int) -> [SubSequence] {
        if count <= size {
            return [self[startIndex..<endIndex]]
        }

        let offset = count % size
        var offsetIndex: Self.Index
        var chunks = [SubSequence]()

        if offset > 0 {
            offsetIndex = index(startIndex, offsetBy: offset)
            chunks.append(self[startIndex..<offsetIndex])
        } else {
            offsetIndex = startIndex
        }

        for _ in stride(from: offset, to: count, by: size) {
            let endIndex = index(offsetIndex, offsetBy: size)
            chunks.append(self[offsetIndex..<endIndex])
            offsetIndex = endIndex
        }

        return chunks
    }
}
