import NIOCore

extension Message {
    struct ParameterStatus: CustomStringConvertible, MessageType {
        let identifier: Identifier = .parameterStatus
        var description: String { "\(name): \(value)" }
        var name: String
        var value: String

        init(buffer: inout ByteBuffer) throws {
            guard let name = buffer.readNullTerminatedString() else {
                throw MessageError("Can't parse parameter status name.")
            }
            guard let value = buffer.readNullTerminatedString() else {
                throw MessageError("Can't parse parameter status value for \(name).")
            }
            self.name = name
            self.value = value
        }
    }
}
