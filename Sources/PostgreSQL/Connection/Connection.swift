import Logging
import NIOCore
import NIOPosix

public final class Connection {
    public let option: Option
    public let logger: Logger
    public internal(set) var serverParameters: [String: String] = .init()
    var backendKeyData: Message.BackendKeyData?
    private var group: EventLoopGroup?
    private var channel: Channel?

    public init(_ option: Option = .init()) {
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
            try await channel.pipeline.addHandler(ByteToMessageHandler(MessageDecoder(connection: self))).get()
            try await channel.pipeline.addHandler(MessageToByteHandler(MessageEncoder())).get()
            try await channel.pipeline.addHandler(RequestHandler(connection: self)).get()
            self.channel = channel

            let message = try await startUp(in: channel)

            if false { // TODO: check if password is needed to authenticate
                let message = try await authenticate(in: channel)
            }
        }

        return self
    }

    public func close() async throws {
        if let channel = channel {
            try await channel.close()
            self.channel = nil
        }

        if let group = group {
            try await group.shutdownGracefully()
            self.group = nil
        }
    }

    @discardableResult
    public func simpleQuery(_ string: String) async throws -> [[String: Any?]] {
        let messageType = Message.SimpleQuery(string)
        let channel = channel!
        let response = try await send(type: messageType, in: channel)

        if let fetchRequest = response.fetchRequest {
            return fetchRequest.result
        }

        return .init()
    }
}

extension Connection {
    private func startUp(in channel: Channel) async throws -> Message {
        let messageType = Message.StartupMessage(user: option.username ?? "", database: option.database)
        return try await send(type: messageType, in: channel).message
    }

    private func authenticate(in channel: Channel) async throws -> Message {
        let messageType = Message.Password(option.password ?? "")
        return try await send(type: messageType, in: channel).message
    }

    private func send(type: MessageType, in channel: Channel) async throws -> Response {
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        type.write(into: &buffer)
        let message = Message(identifier: type.identifier, buffer: buffer)
        let promise = channel.eventLoop.makePromise(of: Response.self)
        let request = Request(message: message, promise: promise)
        try await channel.writeAndFlush(request).get()

        return try await promise.futureResult.get()
    }
}
