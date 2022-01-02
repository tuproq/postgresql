import Logging
import NIOCore
import NIOPosix

public final class Connection {
    public let option: Option
    public let logger: Logger

    private var group: EventLoopGroup?
    private var channel: Channel?

    public init(option: Option = .init()) {
        self.option = option
        logger = .init(label: option.identifier)
    }

    @discardableResult
    public func connect() async throws -> Self {
        if channel == nil {
            let group = MultiThreadedEventLoopGroup(numberOfThreads: option.numberOfThreads)
            self.group = group
            let bootstrap = ClientBootstrap(group: group)
                .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
            let channel = try await bootstrap.connect(host: option.host, port: option.port).get()
            try await channel.pipeline.addHandler(ByteToMessageHandler(MessageDecoder())).get()
            try await channel.pipeline.addHandler(MessageToByteHandler(MessageEncoder())).get()
            try await channel.pipeline.addHandler(RequestHandler(logger: logger)).get()
            self.channel = channel

            let message = try await startUp()

            if false { // TODO: check if password is needed to authenticate
                let message = try await authenticate()
            }
        }

        return self
    }

    public func disconnect() async throws {
        if let channel = channel {
            try await channel.close()
            self.channel = nil
        }

        if let group = group {
            try await group.shutdownGracefully()
            self.group = nil
        }
    }

    public func simpleQuery(_ string: String) async throws -> [String: Any?]? {
        let messageType = Message.Query(string)
        let message = try await send(type: messageType)

        return nil
    }
}

extension Connection {
    private func startUp() async throws -> Message {
        let messageType = Message.Startup(user: option.username ?? "", database: option.database)
        return try await send(type: messageType)
    }

    private func authenticate() async throws -> Message {
        let messageType = Message.Password(option.password ?? "")
        return try await send(type: messageType)
    }

    private func send(type: MessageType) async throws -> Message {
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        type.write(into: &buffer)
        let message = Message(identifier: type.identifier, buffer: buffer)

        if let channel = channel {
            let promise = channel.eventLoop.makePromise(of: Message.self)
            let request = Request(message: message, promise: promise)
            try await channel.writeAndFlush(request).get()
            return try await promise.futureResult.get()
        }

        return message
    }
}
