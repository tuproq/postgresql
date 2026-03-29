import struct NIOCore.EventLoopPromise

final class Request {
    let messages: [Message]
    let promise: EventLoopPromise<Response>
    var results = [Result]()
    let isSSLRequest: Bool

    init(
        messages: [Message],
        promise: EventLoopPromise<Response>,
        isSSLRequest: Bool = false
    ) {
        self.messages = messages
        self.promise = promise
        self.isSSLRequest = isSSLRequest
    }
}
