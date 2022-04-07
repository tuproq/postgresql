import Foundation
import Logging
import NIOCore

final class RequestHandler: ChannelDuplexHandler {
    typealias InboundIn = Message
    typealias OutboundIn = [Request]
    typealias OutboundOut = Message

    let connection: Connection
    private var queue: [Request]
    private var lastFetchRequest: FetchRequest?
    private var isExtendedQuery = false

    init(connection: Connection) {
        self.connection = connection
        queue = .init()
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        guard let request = queue.first else { return }
        var message = unwrapInboundIn(data)

        switch message.identifier {
        case .rowDescription:
            do {
                let rowDescription = try Message.RowDescription(buffer: &message.buffer)
                lastFetchRequest = FetchRequest(columns: rowDescription.columns)
            } catch {
                request.promise.fail(error)
                return
            }
        case .dataRow:
            do {
                let dataRow = try Message.DataRow(buffer: &message.buffer)

                if let fetchRequest = lastFetchRequest {
                    var dictionary = [String: Codable?]()

                    for (index, buffer) in dataRow.values.enumerated() {
                        var buffer = buffer
                        let column = fetchRequest.columns[index]
                        dictionary[column.name] = try value(from: &buffer, for: column)
                    }

                    fetchRequest.result.append(dictionary)
                }
            } catch {
                request.promise.fail(error)
                return
            }
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
        case .readyForQuery:
            var buffer = message.buffer

            do {
                let readyForQuery = try Message.ReadyForQuery(buffer: &buffer)

                switch readyForQuery.status {
                case .idle:
                    queue.removeFirst()

                    if let fetchRequest = lastFetchRequest {
                        let response = Response(message: message, fetchRequest: fetchRequest)
                        request.promise.succeed(response)
                        self.lastFetchRequest = nil
                        return
                    }
                case .transaction:
                    break // TODO: handle
                case .transactionFailed:
                    break // TODO: handle
                }
            } catch {
                connection.logger.error("\(error)")
            }
        case .noticeResponse:
            let buffer = message.buffer
            let warningMessage = buffer.getString(at: 0, length: buffer.readableBytes) ?? "An unknown warning."
            connection.logger.warning("\(warningMessage)")
        case .errorResponse:
            let buffer = message.buffer
            let error = MessageError(buffer.getString(at: 0, length: buffer.readableBytes) ?? "An unknown error.")
            request.promise.fail(error)
            return
        case .parseComplete:
            isExtendedQuery = true
        case .bindComplete:
            isExtendedQuery = true
        case .commandComplete:
            isExtendedQuery = true
            var buffer = message.buffer

            do {
                let commandComplete = try Message.CommandComplete(buffer: &buffer)
            } catch {
                connection.logger.error("\(error)")
            }
        default: break
        }

        if lastFetchRequest == nil && !isExtendedQuery {
            request.promise.succeed(Response(message: message))
        }
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let requests = unwrapOutboundIn(data)
        
        for request in requests {
            queue.append(request)
            context.write(wrapOutboundOut(request.message), promise: promise)
        }
    }

    private func value(from buffer: inout ByteBuffer?, for column: Column) throws -> Codable? {
        if var buffer = buffer {
            let format = column.dataFormat
            let type = column.dataType

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
