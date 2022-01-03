import Logging
import NIOCore

final class RequestHandler: ChannelDuplexHandler {
    typealias InboundIn = Message
    typealias OutboundIn = Request
    typealias OutboundOut = Message

    let logger: Logger
    private var queue: [Request]
    private var lastQuery: SimpleQuery?

    init(logger: Logger) {
        self.logger = logger
        queue = .init()
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        guard let request = queue.first else { return }
        var message = unwrapInboundIn(data)

        switch message.identifier {
        case .rowDescription:
            do {
                let rowDescription = try Message.RowDescription(buffer: &message.buffer)
                lastQuery = SimpleQuery(columns: rowDescription.columns.map { $0.name })
            } catch {
                request.promise.fail(error)
                return
            }
        case .dataRow:
            do {
                let dataRow = try Message.DataRow(buffer: &message.buffer)

                if let query = lastQuery {
                    query.rows.append(dataRow.values.map {
                        if let value = $0 { return value.getString(at: 0, length: value.readableBytes) }
                        return nil
                    })
                }
            } catch {
                request.promise.fail(error)
                return
            }
        case .readyForQuery:
            queue.removeFirst()
        case .noticeResponse:
            let buffer = message.buffer
            let warningMessage = buffer.getString(at: 0, length: buffer.readableBytes) ?? "An unknown warning."
            logger.warning("\(warningMessage)")
        case .errorResponse:
            let buffer = message.buffer
            let error = MessageError(buffer.getString(at: 0, length: buffer.readableBytes) ?? "An unknown error.")
            request.promise.fail(error)
            return
        default: break
        }

        request.promise.succeed(message)
    }

    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let request = unwrapOutboundIn(data)
        queue.append(request)
        context.write(wrapOutboundOut(request.message), promise: promise)
    }
}
