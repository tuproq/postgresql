import NIOCore

struct Request {
    var message: Message
    var promise: EventLoopPromise<Message>
}
