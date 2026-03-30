import Foundation

struct Numeric {
    let chunkSize = 4
    let negativeSign: Int16 = 0x4000
    let zero = "0"

    var ndigits: Int16
    var weight: Int16
    var sign: Int16
    var dscale: Int16
    var digits: [Int16]

    var decimal: Decimal? { .init(string: string, locale: .init(identifier: "en_US_POSIX")) }

    var string: String {
        guard ndigits > 0 else { return zero }
        var integer = ""
        var fraction = ""

        for offset in 0..<ndigits {
            let character = digits[Int(offset)]
            let characterString = character.description

            if weight - offset >= 0 {
                if offset == 0 {
                    integer += characterString
                } else {
                    integer += String(repeating: zero, count: chunkSize - characterString.count) + characterString
                }
            } else {
                fraction += String(repeating: zero, count: chunkSize - characterString.count) + characterString
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
                    integer = integer + String(repeating: zero, count: chunkSize)
                } else {
                    fraction = String(repeating: zero, count: chunkSize) + fraction
                }
            }
        }

        if integer.count == 0 {
            integer = zero
        }

        if fraction.count > dscale {
            let lastSignificant = fraction.index(fraction.startIndex, offsetBy: Int(dscale))
            fraction = String(fraction[..<lastSignificant])
        }

        let numeric = fraction.isEmpty ? integer : "\(integer).\(fraction)"

        return (sign & negativeSign) == 0 ? numeric : "-\(numeric)"
    }

    init?(buffer: inout ByteBuffer) {
        guard let ndigits = buffer.readInteger(as: Int16.self),
              let weight = buffer.readInteger(as: Int16.self),
              let sign = buffer.readInteger(as: Int16.self),
              let dscale = buffer.readInteger(as: Int16.self) else { return nil }
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

        for chunk in integer.chunkFromEnd(by: chunkSize) {
            weight += 1
            encodedDigits.append(Int16(chunk) ?? 0)
        }

        var dscale = 0

        if let fraction = fraction {
            for chunk in fraction.chunkFromStart(by: chunkSize) {
                dscale += chunk.count
                let paddedChunk = chunk + String(repeating: zero, count: chunkSize - chunk.count)
                encodedDigits.append(Int16(paddedChunk) ?? 0)
            }
        }

        ndigits = Int16(encodedDigits.count)
        self.weight = numericCast(weight)
        sign = isNegative ? negativeSign : 0
        self.dscale = numericCast(dscale)
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
