import struct NIOCore.EventLoopPromise

struct Request {
    var message: Message
    var promise: EventLoopPromise<Response>
}
