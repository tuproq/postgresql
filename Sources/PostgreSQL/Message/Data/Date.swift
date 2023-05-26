import Foundation

extension Date: PostgreSQLCodable {
    public static var psqlType: DataType { .timestamptz }

    static let microsecondsInSecond: TimeInterval = 1_000_000
    static let secondsInDay: TimeInterval = 86_400
    static let secondsFrom1970To2000: TimeInterval = 946_684_800
    static let startDate = Date(timeIntervalSince1970: secondsFrom1970To2000)

    private static let formatter = DateFormatter()

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch format {
        case .binary:
            switch type {
            case .date:
                guard buffer.readableBytes == 4, let days = buffer.readInteger(as: Int32.self) else {
                    throw postgreSQLError(.invalidData(format: format, type: type))
                }
                let seconds = TimeInterval(days) * Self.secondsInDay
                self = Date(timeInterval: seconds, since: Self.startDate)
            case .timestamp, .timestamptz:
                guard buffer.readableBytes == 8, let microseconds = buffer.readInteger(as: Int64.self) else {
                    throw postgreSQLError(.invalidData(format: format, type: type))
                }
                let seconds = TimeInterval(microseconds) / Self.microsecondsInSecond
                self = Date(timeInterval: seconds, since: Self.startDate)
            default: throw postgreSQLError(.invalidDataType(type))
            }
        case .text:
            guard let dateString = buffer.readString() else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }

            switch type {
            case .date: Self.formatter.dateFormat = "yyyy-MM-dd"
            case .timestamp: Self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            case .timestamptz: Self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ssxxxxx"
            default: throw postgreSQLError(.invalidDataType(type))
            }

            var date = Self.formatter.date(from: dateString)

            if type == .timestamptz, date == nil {
                Self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSxxxxx"
                date = Self.formatter.date(from: dateString)
            }

            guard let date = date else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }

            self = date
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch format {
        case .binary:
            if type == .date {
                let calendar = Calendar.current
                let days = calendar.dateComponents([.day], from: Self.startDate, to: self).day!
                buffer.writeInteger(Int32(days))
            } else if type == .timestamp || type == .timestamptz {
                let seconds = timeIntervalSince(Self.startDate) * Self.microsecondsInSecond
                buffer.writeInteger(Int64(seconds))
            } else {
                throw postgreSQLError(.invalidDataType(type))
            }
        case .text:
            switch type {
            case .date: Self.formatter.dateFormat = "yyyy-MM-dd"
            case .timestamp: Self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            case .timestamptz: Self.formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSxxxxx"
            default: throw postgreSQLError(.invalidDataType(type))
            }

            let dateString = Self.formatter.string(from: self)
            buffer.writeString(dateString)
        }
    }
}
