import struct NIOCore.EventLoopPromise

final class Request {
    let message: Message
    let promise: EventLoopPromise<Response>
    var results = [Result]()

    init(message: Message, promise: EventLoopPromise<Response>) {
        self.message = message
        self.promise = promise
    }
}
