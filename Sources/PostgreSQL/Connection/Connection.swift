import Logging
import NIOCore
import NIOPosix

public final class Connection {
    public let option: Option
    public let logger: Logger
    public internal(set) var serverParameters = [String: String]()
    var backendKeyData: Message.BackendKeyData?
    private var group: EventLoopGroup?
    private var channel: Channel?

    public init(_ option: Option = .init()) {
        self.option = option
        logger = .init(label: option.identifier)
    }

    public func open() async throws {
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

            if option.requiresTLS {
                let message = try await sslRequest(in: channel)

                if message.identifier == .sslSupported {
                    // TODO: implement SSL handshake
                } else {
                    let message = try await _connect(in: channel)
                }
            } else {
                let message = try await _connect(in: channel)
            }
        }
    }

    private func _connect(in channel: Channel) async throws -> Message {
        let message = try await startupMessage(in: channel)

        if false { // TODO: check if password is needed to authenticate
            let message = try await authenticate(in: channel)
        }

        return message
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
    public func simpleQuery(_ string: String) async throws -> [Result] {
        let messageType = Message.SimpleQuery(string)
        return try await send(types: [messageType], in: channel!).results
    }

    @discardableResult
    public func query(
        _ string: String,
        name: String = "",
        arguments parameters: PostgreSQLCodable?...
    ) async throws -> Result? {
        try await query(string, name: name, arguments: parameters)
    }

    @discardableResult
    public func query(
        _ string: String,
        name: String = "",
        arguments parameters: [PostgreSQLCodable?] = .init()
    ) async throws -> Result? {
        let formats: [DataFormat] = parameters.map {
            if let parameter = $0 {
                return type(of: parameter).psqlFormat
            }

            return .binary
        }
        let types: [DataType] = parameters.map {
            if let parameter = $0 {
                return type(of: parameter).psqlType
            }

            return .null
        }
        let parameters: [ByteBuffer?] = try parameters.map {
            var buffer = ByteBuffer()
            try $0?.encode(into: &buffer)

            return buffer
        }
        let command: Message.Command = name.isEmpty ? .portal : .statement
        let response = try await send(
            types: [
                Message.Parse(statementName: name, query: string, parameterTypes: types),
                Message.Bind(
                    statementName: name,
                    parameterDataFormats: formats,
                    parameters: parameters,
                    resultDataFormats: [.binary]
                ),
                Message.Describe(command: command),
                Message.Execute(),
                Message.Close(command: command, name: name),
                Message.Sync()
            ],
            in: channel!
        )

        return response.results.first
    }

    public func beginTransaction() async throws {
        try await query("BEGIN;")
    }

    public func commitTransaction() async throws {
        try await query("COMMIT;")
    }

    public func rollbackTransaction() async throws {
        try await query("ROLLBACK;")
    }
}

extension Connection {
    private func sslRequest(in channel: Channel) async throws -> Message {
        let messageType = Message.SSLRequest()
        return try await send(types: [messageType], in: channel).message
    }

    private func startupMessage(in channel: Channel) async throws -> Message {
        let messageType = Message.StartupMessage(user: option.username ?? "", database: option.database)
        return try await send(types: [messageType], in: channel).message
    }

    private func authenticate(in channel: Channel) async throws -> Message {
        let messageType = Message.Password(option.password ?? "")
        return try await send(types: [messageType], in: channel).message
    }

    @discardableResult
    private func send(types: [MessageType], in channel: Channel) async throws -> Response {
        var requests = [Request]()
        let promise = channel.eventLoop.makePromise(of: Response.self)

        for type in types {
            var buffer = ByteBuffer()
            type.encode(into: &buffer)
            let message = Message(identifier: type.identifier, source: .frontend, buffer: buffer)
            let request = Request(message: message, promise: promise)
            requests.append(request)
        }

        try await channel.writeAndFlush(requests).get()

        return try await promise.futureResult.get()
    }
}
