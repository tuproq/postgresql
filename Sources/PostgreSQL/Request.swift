import struct NIOCore.EventLoopPromise

final class Request {
    let message: Message
    let promise: EventLoopPromise<Response>
    var result: Result?

    init(message: Message, promise: EventLoopPromise<Response>) {
        self.message = message
        self.promise = promise
    }
}
