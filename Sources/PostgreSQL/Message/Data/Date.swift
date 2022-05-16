import Foundation

extension Date: Codable {
    public static var psqlType: DataType { .timestamptz }

    static let microsecondsInSecond: TimeInterval = 1_000_000
    static let secondsInDay: TimeInterval = 86_400
    static let secondsFrom1970To2000: TimeInterval = 946_684_800
    static let startDate = Date(timeIntervalSince1970: secondsFrom1970To2000)

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch type {
        case .date:
            guard buffer.readableBytes == 4, let days = buffer.readInteger(as: Int32.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            let seconds = TimeInterval(days) * Self.secondsInDay
            self = Date(timeInterval: seconds, since: Self.startDate)
        case .timestamp, .timestamptz:
            guard buffer.readableBytes == 8, let microseconds = buffer.readInteger(as: Int64.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            let seconds = TimeInterval(microseconds) / Self.microsecondsInSecond
            self = Date(timeInterval: seconds, since: Self.startDate)
        default: throw error(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch type {
        case .date:
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: Self.startDate, to: self).day!
            buffer.writeInteger(Int32(days))
        case .timestamp, .timestamptz:
            let seconds = timeIntervalSince(Self.startDate) * Self.microsecondsInSecond
            buffer.writeInteger(Int64(seconds))
        default: throw error(.invalidDataType(type))
        }
    }
}
