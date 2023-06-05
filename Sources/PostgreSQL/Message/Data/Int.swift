extension Int16: PostgreSQLCodable {
    public static var psqlType: DataType { .int2 }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .int2):
            guard buffer.readableBytes == 2, let value = buffer.readInteger(as: Self.self) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = value
        case (.text, .int2):
            guard let string = buffer.readString(), let value = Self(string) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = value
        default: throw postgreSQLError(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        if type == .int2 {
            switch format {
            case .binary: buffer.writeInteger(self)
            case .text: buffer.writeString(String(self))
            }
        } else {
            throw postgreSQLError(.invalidDataType(type))
        }
    }
}

extension Int32: PostgreSQLCodable {
    public static var psqlType: DataType { .int4 }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .int2):
            guard buffer.readableBytes == 2, let value = buffer.readInteger(as: Int16.self) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.binary, .int4), (.binary, .oid):
            guard buffer.readableBytes == 4, let value = buffer.readInteger(as: Self.self) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.text, .int2), (.text, .int4), (.text, .oid):
            guard let string = buffer.readString(), let value = Self(string) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = value
        default: throw postgreSQLError(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        if type == .int2 || type == .int4 {
            switch format {
            case .binary: buffer.writeInteger(self)
            case .text: buffer.writeString(String(self))
            }
        } else {
            throw postgreSQLError(.invalidDataType(type))
        }
    }
}

extension Int64: PostgreSQLCodable {
    public static var psqlType: DataType { .int8 }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .int2):
            guard buffer.readableBytes == 2, let value = buffer.readInteger(as: Int16.self) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.binary, .int4):
            guard buffer.readableBytes == 4, let value = buffer.readInteger(as: Int32.self) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.binary, .int8):
            guard buffer.readableBytes == 8, let value = buffer.readInteger(as: Self.self) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = value
        case (.text, .int2), (.text, .int4), (.text, .int8):
            guard let string = buffer.readString(), let value = Self(string) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = value
        default: throw postgreSQLError(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        if type == .int2 || type == .int4 || type == .int8 {
            switch format {
            case .binary: buffer.writeInteger(self)
            case .text: buffer.writeString(String(self))
            }
        } else {
            throw postgreSQLError(.invalidDataType(type))
        }
    }
}

extension Int: PostgreSQLCodable {
    public static var psqlType: DataType {
        MemoryLayout<Int>.size == 8 ? .int8 : .int4
    }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .int2):
            guard buffer.readableBytes == 2, let value = buffer.readInteger(as: Int16.self) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.binary, .int4):
            guard buffer.readableBytes == 4, let value = buffer.readInteger(as: Int32.self) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.binary, .int8):
            guard buffer.readableBytes == 8, let value = buffer.readInteger(as: Int64.self) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.text, .int2), (.text, .int4), (.text, .int8):
            guard let string = buffer.readString(), let value = Self(string) else {
                throw postgreSQLError(.invalidData(format: format, type: type))
            }
            self = value
        default: throw postgreSQLError(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        if type == .int2 || type == .int4 || type == .int8 {
            switch format {
            case .binary: buffer.writeInteger(self)
            case .text: buffer.writeString(String(self))
            }
        } else {
            throw postgreSQLError(.invalidDataType(type))
        }
    }
}
