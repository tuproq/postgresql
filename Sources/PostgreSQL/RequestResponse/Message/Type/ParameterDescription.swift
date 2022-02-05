import NIOCore

extension Message {
    struct ParameterDescription: MessageType {
        let identifier: Identifier = .parameterDescription
        let dataTypes: [Column.DataType]

        init(buffer: inout ByteBuffer) throws {
            guard let dataTypes = try buffer.readArray(as: Column.DataType.self, { buffer in
                guard let dataType = buffer.readInteger(as: Column.DataType.self) else {
                    throw MessageError("Can't parse parameter data type.")
                }
                return dataType
            }) else {
                throw MessageError("Can't parse parameter data types.")
            }
            self.dataTypes = dataTypes
        }
    }
}