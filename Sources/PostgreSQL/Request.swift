import struct NIOCore.EventLoopPromise

final class Request {
    let messages: [Message]
    let promise: EventLoopPromise<Response>

    init(messages: [Message], promise: EventLoopPromise<Response>) {
        self.messages = messages
        self.promise = promise
    }
}
