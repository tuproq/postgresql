import Foundation
import NIOCore

struct Numeric {
    let chunkSize = 4
    let negativeSign: Int16 = 0x4000
    let zero = "0"

    var ndigits: Int16
    var weight: Int16
    var sign: Int16
    var dscale: Int16
    var value: ByteBuffer

    var decimal: Decimal { Decimal(string: string)! }

    var string: String {
        guard ndigits > 0 else { return zero }
        var integer = ""
        var fraction = ""
        var value = self.value

        for offset in 0..<ndigits {
            let character = value.readInteger(as: Int16.self) ?? 0
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
        value = buffer
    }

    init(decimal: Decimal) {
        self.init(string: decimal.description)
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

        var buffer = ByteBuffer()
        var weight = -1

        for chunk in integer.chunkFromEnd(by: chunkSize) {
            weight += 1
            buffer.writeInteger(Int16(chunk)!)
        }

        var dscale = 0

        if let fraction = fraction {
            for chunk in fraction.chunkFromStart(by: chunkSize) {
                dscale += chunk.count
                let string = chunk + String(repeating: zero, count: chunkSize - chunk.count)
                buffer.writeInteger(Int16(string)!)
            }
        }

        ndigits = numericCast(buffer.readableBytes / 2)
        self.weight = numericCast(weight)
        sign = isNegative ? negativeSign : 0
        self.dscale = numericCast(dscale)
        value = buffer
    }
}
