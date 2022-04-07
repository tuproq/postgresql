extension Int16: Codable {
    public static var psqlType: DataType { .int2 }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .int2):
            guard buffer.readableBytes == 2, let value = buffer.readInteger(as: Self.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = value
        case (.text, .int2):
            guard let string = buffer.readString(), let value = Self(string) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = value
        default: throw error(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) {
        switch format {
        case .binary: buffer.writeInteger(self, as: Self.self)
        case .text: buffer.writeString(String(self))
        }
    }
}

extension Int32: Codable {
    public static var psqlType: DataType { .int4 }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .int2):
            guard buffer.readableBytes == 2, let value = buffer.readInteger(as: Int16.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.binary, .int4):
            guard buffer.readableBytes == 4, let value = buffer.readInteger(as: Self.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.text, .int2), (.text, .int4):
            guard let string = buffer.readString(), let value = Self(string) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = value
        default: throw error(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) {
        switch format {
        case .binary: buffer.writeInteger(self, as: Int32.self)
        case .text: buffer.writeString(String(self))
        }
    }
}

extension Int64: Codable {
    public static var psqlType: DataType { .int8 }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .int2):
            guard buffer.readableBytes == 2, let value = buffer.readInteger(as: Int16.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.binary, .int4):
            guard buffer.readableBytes == 4, let value = buffer.readInteger(as: Int32.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.binary, .int8):
            guard buffer.readableBytes == 8, let value = buffer.readInteger(as: Self.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = value
        case (.text, .int2), (.text, .int4), (.text, .int8):
            guard let string = buffer.readString(), let value = Self(string) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = value
        default: throw error(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) {
        switch format {
        case .binary: buffer.writeInteger(self, as: Int64.self)
        case .text: buffer.writeString(String(self))
        }
    }
}

extension Int: Codable {
    public static var psqlType: DataType {
        switch MemoryLayout<Int>.size {
        case 4: return .int4
        case 8: return .int8
        default: preconditionFailure("The `psqlType` must be either an Int32 or Int64.")
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat, type: DataType) throws {
        switch (format, type) {
        case (.binary, .int2):
            guard buffer.readableBytes == 2, let value = buffer.readInteger(as: Int16.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.binary, .int4):
            guard buffer.readableBytes == 4, let value = buffer.readInteger(as: Int32.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.binary, .int8):
            guard buffer.readableBytes == 8, let value = buffer.readInteger(as: Int64.self) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = Self(value)
        case (.text, .int2), (.text, .int4), (.text, .int8):
            guard let string = buffer.readString(), let value = Self(string) else {
                throw error(.invalidData(format: format, type: type))
            }
            self = value
        default: throw error(.invalidDataType(type))
        }
    }

    public init(buffer: inout ByteBuffer, format: DataFormat = Self.psqlFormat) throws {
        try self.init(buffer: &buffer, format: format, type: Self.psqlType)
    }

    public func encode(into buffer: inout ByteBuffer, format: DataFormat, type: DataType) {
        switch format {
        case .binary: buffer.writeInteger(self, as: Int.self)
        case .text: buffer.writeString(String(self))
        }
    }
}
