import Logging
import NIOCore

final class RequestHandler: ChannelDuplexHandler {
    typealias InboundIn = Message
    typealias OutboundIn = Request
    typealias OutboundOut = Message

    let connection: Connection
    private var queue: [Request]
    private var lastFetchRequest: FetchRequest?

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
                lastFetchRequest = FetchRequest(columns: rowDescription.columns.map { $0.name })
            } catch {
                request.promise.fail(error)
                return
            }
        case .dataRow:
            do {
                let dataRow = try Message.DataRow(buffer: &message.buffer)

                if let fetchRequest = lastFetchRequest {
                    var dictionary = [String: Any?]()

                    for (index, value) in dataRow.values.enumerated() {
                        let column = fetchRequest.columns[index]

                        if let value = value {
                            let value = value.getString(at: 0, length: value.readableBytes)
                            dictionary[column] = value
                        } else {
                            dictionary[column] = nil
                        }
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
                let errorMessage = buffer.getString(at: 0, length: buffer.readableBytes) ?? "An unknown error."
                connection.logger.error("\(errorMessage)")
            }
        case .backendKeyData:
            var buffer = message.buffer

            do {
                connection.backendKeyData = try Message.BackendKeyData(buffer: &buffer)
            } catch {
                let errorMessage = buffer.getString(at: 0, length: buffer.readableBytes) ?? "An unknown error."
                connection.logger.error("\(errorMessage)")
            }
        case .readyForQuery:
            queue.removeFirst()

            if let fetchRequest = lastFetchRequest {
                let response = Response(message: message, fetchRequest: fetchRequest)
                request.promise.succeed(response)
                self.lastFetchRequest = nil
                return
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
        default: break
        }

        if lastFetchRequest == nil {
            request.promise.succeed(Response(message: message))
        }
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let request = unwrapOutboundIn(data)
        queue.append(request)
        context.write(wrapOutboundOut(request.message), promise: promise)
    }
}
