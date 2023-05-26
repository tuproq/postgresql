import Foundation
import Logging
import NIOCore

final class RequestHandler: ChannelDuplexHandler {
    typealias InboundIn = Message
    typealias OutboundIn = Request
    typealias OutboundOut = Message

    let connection: PostgreSQL
    private var request: Request?
    private var firstError: Error?
    private var results = [Result]()

    init(connection: PostgreSQL) {
        self.connection = connection
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        var message = unwrapInboundIn(data)
        var buffer = message.buffer

        switch message.identifier {
        case .authentication:
            request?.promise.succeed(Response(message: message))
        case .parameterStatus:
            do {
                let parameterStatus = try Message.ParameterStatus(buffer: &buffer)
                connection.serverParameters[parameterStatus.name] = parameterStatus.value
            } catch {
                connection.logger.error("\(error)")
            }
        case .backendKeyData:
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
                    var row = [PostgreSQLCodable?]()

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
        case .errorResponse:
            do {
                let errorResponse = try Message.ErrorResponse(buffer: &buffer)
                let message = errorResponse.fields[.message] ?? "An unknown error."
                let error = PostgreSQLError(message)
                setError(error)
            } catch {
                connection.logger.error("\(error)")
            }
        case .noticeResponse:
            do {
                let noticeResponse = try Message.NoticeResponse(buffer: &buffer)
                let message = noticeResponse.fields[.message] ?? "An unknown warning."
                connection.logger.warning("\(message)")
            } catch {
                connection.logger.error("\(error)")
            }
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

    private func decode(from buffer: inout ByteBuffer?, to column: Column) throws -> PostgreSQLCodable? {
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

    private func setError(_ error: Error) {
        if firstError == nil {
            firstError = error
        }
    }
}
