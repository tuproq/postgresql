import Foundation
import Logging
import NIOCore

final class RequestHandler: ChannelDuplexHandler {
    typealias InboundIn = Message
    typealias OutboundIn = Request
    typealias OutboundOut = Message

    let connection: Connection
    private var request: Request?
    private var firstError: Error?
    private var results = [Result]()

    init(connection: Connection) {
        self.connection = connection
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var message = unwrapInboundIn(data)

        switch message.identifier {
        case .authentication:
            request?.promise.succeed(Response(message: message))
        case .parameterStatus:
            var buffer = message.buffer

            do {
                let parameterStatus = try Message.ParameterStatus(buffer: &buffer)
                connection.serverParameters[parameterStatus.name] = parameterStatus.value
            } catch {
                connection.logger.error("\(error)")
            }
        case .backendKeyData:
            var buffer = message.buffer

            do {
                connection.backendKeyData = try Message.BackendKeyData(buffer: &buffer)
            } catch {
                connection.logger.error("\(error)")
            }
        case .rowDescription:
            do {
                let rowDescription = try Message.RowDescription(buffer: &message.buffer)
                results.append(Result(columns: rowDescription.columns))
            } catch {
                connection.logger.error("\(error)")
            }
        case .dataRow:
            do {
                let dataRow = try Message.DataRow(buffer: &message.buffer)

                if let result = results.last {
                    var row = [Codable?]()

                    for (index, buffer) in dataRow.values.enumerated() {
                        var buffer = buffer
                        let column = result.columns[index]
                        row.append(try decode(from: &buffer, to: column))
                    }

                    result.rows.append(row)
                }
            } catch {
                connection.logger.error("\(error)")
            }
        case .readyForQuery:
            var buffer = message.buffer

            if let error = firstError {
                request?.promise.fail(error)
            } else {
                do {
                    let readyForQuery = try Message.ReadyForQuery(buffer: &buffer)

                    switch readyForQuery.status {
                    case .idle:
                        let response = Response(message: message, results: results)
                        request?.promise.succeed(response)
                    case .transaction:
                        request?.promise.succeed(Response(message: message))
                    case .transactionFailed:
                        break // TODO: handle
                    }
                } catch {
                    connection.logger.error("\(error)")
                }
            }

            request = nil
            firstError = nil
            results.removeAll()
        case .noticeResponse:
            let warningMessage = getString(message) ?? "An unknown warning."
            connection.logger.warning("\(warningMessage)")
        case .errorResponse:
            let error = ClientError(getString(message) ?? "An unknown error.")
            setError(error)
        default:
            break
        }
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let request = unwrapOutboundIn(data)
        self.request = request

        for message in request.messages {
            context.write(wrapOutboundOut(message), promise: promise)
        }
    }

    private func setError(_ error: Error) {
        if firstError == nil {
            firstError = error
        }
    }

    private func getString(_ message: Message) -> String? {
        message.buffer.getString(at: 0, length: message.buffer.readableBytes)
    }

    private func decode(from buffer: inout ByteBuffer?, to column: Column) throws -> Codable? {
        if var buffer = buffer {
            let format = column.dataFormat
            let type = column.dataTypeID

            switch type {
            case .bool: return try Bool(buffer: &buffer, format: format, type: type)
            case .bytea: return try Data(buffer: &buffer, format: format, type: type)
            case .char: return try UInt8(buffer: &buffer, format: format, type: type)
            case .float4: return try Float(buffer: &buffer, format: format, type: type)
            case .float8: return try Double(buffer: &buffer, format: format, type: type)
            case .int2: return try Int16(buffer: &buffer, format: format, type: type)
            case .int4: return try Int32(buffer: &buffer, format: format, type: type)
            case .int8: return try Int64(buffer: &buffer, format: format, type: type)
            case .name: return try String(buffer: &buffer, format: format, type: type)
            case .numeric: return try Decimal(buffer: &buffer, format: format, type: type)
            case .timestamp, .timestamptz, .date: return try Date(buffer: &buffer, format: format, type: type)
            case .uuid: return try UUID(buffer: &buffer, format: format, type: type)
            case .varchar, .text:
                do {
                    return try UUID(buffer: &buffer, format: format, type: type)
                } catch {
                    return try String(buffer: &buffer, format: format, type: type)
                }
            default: return buffer.readString()
            }
        }

        return nil
    }
}
