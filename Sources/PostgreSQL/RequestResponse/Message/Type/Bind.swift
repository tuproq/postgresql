import NIOCore

extension Message {
    struct Bind: MessageType {
        let identifier: Identifier = .bind
        let portalName: String
        let statementName: String
        let parameterDataFormats: [DataFormat]
        let parameters: [ByteBuffer?]
        let resultDataFormats: [DataFormat]

        init(
            portalName: String = "",
            statementName: String = "",
            parameterDataFormats: [DataFormat] = .init(),
            parameters: [ByteBuffer?] = .init(),
            resultDataFormats: [DataFormat] = .init()
        ) {
            self.portalName = portalName
            self.statementName = statementName
            self.parameterDataFormats = parameterDataFormats
            self.parameters = parameters
            self.resultDataFormats = resultDataFormats
        }

        func write(into buffer: inout ByteBuffer) {
            buffer.writeNullTerminatedString(portalName)
            buffer.writeNullTerminatedString(statementName)
            buffer.writeArray(parameterDataFormats)
            buffer.writeArray(parameters) {
                if var value = $1 {
                    $0.writeInteger(numericCast(value.readableBytes), as: Int32.self)
                    $0.writeBuffer(&value)
                } else {
                    $0.writeInteger(-1, as: Int32.self)
                }
            }
            buffer.writeArray(resultDataFormats)
        }
    }
}
