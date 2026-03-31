import Foundation

extension Date: PostgreSQLCodable {
    public static var psqlType: DataType { .timestamptz }

    static let microsecondsInSecond: TimeInterval = 1_000_000
    static let secondsInDay: TimeInterval = 86_400
    static let secondsFrom1970To2000: TimeInterval = 946_684_800
    static let startDate = Date(timeIntervalSince1970: secondsFrom1970To2000)

    /// Create a fresh `DateFormatter` configured for PostgreSQL text-format dates.
    ///
    /// A new instance is returned on every call.  `DateFormatter` is not thread-safe,
    /// so a shared `static let` would race when multiple NIO event-loop threads decode
    /// date columns concurrently.  Thread-local caching would avoid repeated allocation,
    /// but the text-format path is never exercised by normal queries — `query()` always
    /// requests binary results, and `simpleQuery()` is the only path that can return
    /// text-format columns.  The per-call cost is therefore negligible and the simpler
    /// approach keeps this code free of NIO thread-identity assumptions.
    ///
    /// The formatter is pinned to `en_US_POSIX` locale (avoids locale-dependent digit /
    /// AM-PM formatting) and UTC time zone (PostgreSQL text timestamps are in UTC).
    private static func makeFormatter(dateFormat: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .init(identifier: "en_US_POSIX")
        formatter.timeZone = .init(secondsFromGMT: 0)
        formatter.dateFormat = dateFormat

        return formatter
    }

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

            let dateFormat: String

            switch type {
            case .date: dateFormat = "yyyy-MM-dd"
            case .timestamp: dateFormat = "yyyy-MM-dd HH:mm:ss"
            case .timestamptz: dateFormat = "yyyy-MM-dd HH:mm:ssxxxxx"
            default: throw postgreSQLError(.invalidDataType(type))
            }

            var date = Self.makeFormatter(dateFormat: dateFormat).date(from: dateString)

            if type == .timestamptz, date == nil {
                // PostgreSQL sends timestamptz with up to 6 fractional-second digits
                // (microseconds), e.g. "2024-06-15 10:30:00.123456+00".  The 3-digit
                // SSS pattern only covers millisecond precision; use SSSSSS to match
                // the full microsecond range that PostgreSQL actually emits.
                date = Self.makeFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss.SSSSSSxxxxx").date(from: dateString)
            }

            // PostgreSQL text timestamps often include sub-second precision (e.g. "2024-01-15 12:34:56.789012").
            // The primary format strings above omit fractional seconds, so retry with up to 6-digit
            // fractional seconds when the initial parse fails.
            if type == .timestamp, date == nil {
                date = Self.makeFormatter(dateFormat: "yyyy-MM-dd HH:mm:ss.SSSSSS").date(from: dateString)
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
                let days = Int32(timeIntervalSince(Self.startDate) / Self.secondsInDay)
                buffer.writeInteger(days)
            } else if type == .timestamp || type == .timestamptz {
                let seconds = timeIntervalSince(Self.startDate) * Self.microsecondsInSecond
                buffer.writeInteger(Int64(seconds.rounded()))
            } else {
                throw postgreSQLError(.invalidDataType(type))
            }
        case .text:
            let dateFormat: String

            switch type {
            case .date: dateFormat = "yyyy-MM-dd"
            case .timestamp: dateFormat = "yyyy-MM-dd HH:mm:ss"
            case .timestamptz: dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSxxxxx"
            default: throw postgreSQLError(.invalidDataType(type))
            }

            let dateString = Self.makeFormatter(dateFormat: dateFormat).string(from: self)
            buffer.writeString(dateString)
        }
    }
}
