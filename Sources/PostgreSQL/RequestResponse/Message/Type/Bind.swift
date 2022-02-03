import NIOCore

extension Message {
    struct Bind: MessageType {
        let identifier: Identifier = .bind
        let portalName: String
        let statementName: String
        let parameterFormatCodes: [Column.FormatCode]
        let parameters: [ByteBuffer?]
        let resultFormatCodes: [Column.FormatCode]

        init(
            portalName: String = "",
            statementName: String = "",
            parameterFormatCodes: [Column.FormatCode] = .init(),
            parameters: [ByteBuffer?] = .init(),
            resultFormatCodes: [Column.FormatCode] = .init()
        ) {
            self.portalName = portalName
            self.statementName = statementName
            self.parameterFormatCodes = parameterFormatCodes
            self.parameters = parameters
            self.resultFormatCodes = resultFormatCodes
        }

        func write(into buffer: inout ByteBuffer) {
            buffer.writeNullTerminatedString(portalName)
            buffer.writeNullTerminatedString(statementName)
            buffer.writeArray(parameterFormatCodes)
            buffer.writeArray(parameters) {
                if var value = $1 {
                    $0.writeInteger(numericCast(value.readableBytes), as: Int32.self)
                    $0.writeBuffer(&value)
                } else {
                    $0.writeInteger(-1, as: Int32.self)
                }
            }
            buffer.writeArray(resultFormatCodes)
        }
    }
}
