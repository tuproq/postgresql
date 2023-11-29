import Logging
import NIOCore
import NIOPosix

public final class PostgreSQL {
    public let eventLoopGroup: EventLoopGroup
    public let configuration: Configuration
    public let logger: Logger
    public let channel: Channel
    public private(set) var isOpen = false
    public internal(set) var serverParameters = [String: String]()
    var backendKeyData: Message.BackendKeyData?

    public init(eventLoopGroup: EventLoopGroup? = nil, configuration: Configuration = .init()) async throws {
        self.eventLoopGroup = eventLoopGroup ?? MultiThreadedEventLoopGroup.singleton
        self.configuration = configuration
        logger = .init(label: configuration.identifier)

        let bootstrap = ClientBootstrap(group: self.eventLoopGroup)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(IPPROTO_TCP), TCP_NODELAY), value: 1)
        channel = try await bootstrap.connect(host: configuration.host, port: configuration.port).get()
        try await channel.pipeline.addHandler(ByteToMessageHandler(MessageDecoder(connection: self))).get()
        try await channel.pipeline.addHandler(MessageToByteHandler(MessageEncoder())).get()
        try await channel.pipeline.addHandler(RequestHandler(connection: self)).get()

        if configuration.requiresTLS {
            let message = try await sslRequest()

            if message.identifier == .sslSupported {
                // TODO: implement SSL handshake
            } else {
                let message = try await _connect()
            }
        } else {
            let message = try await _connect()
        }

        isOpen = true
    }

    private func _connect() async throws -> Message {
        let message = try await startupMessage()

        if false { // TODO: check if password is needed to authenticate
            let message = try await authenticate()
        }

        return message
    }

    public func close() async throws {
        if isOpen {
            isOpen = false
            try await channel.close()
            try await eventLoopGroup.shutdownGracefully()
        }
    }

    @discardableResult
    public func simpleQuery(_ string: String) async throws -> [Result] {
        let messageType = Message.SimpleQuery(string)
        return try await send(types: [messageType]).results
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
        arguments parameters: [PostgreSQLCodable?]
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
            ]
        )

        return response.results.first
    }

    public func beginTransaction() async throws {
        try await simpleQuery("BEGIN;")
    }

    public func commitTransaction() async throws {
        try await simpleQuery("COMMIT;")
    }

    public func rollbackTransaction() async throws {
        try await simpleQuery("ROLLBACK;")
    }
}

extension PostgreSQL {
    private func sslRequest() async throws -> Message {
        let messageType = Message.SSLRequest()
        return try await send(types: [messageType]).message
    }

    private func startupMessage() async throws -> Message {
        let messageType = Message.StartupMessage(user: configuration.username ?? "", database: configuration.database)
        return try await send(types: [messageType]).message
    }

    private func authenticate() async throws -> Message {
        let messageType = Message.Password(configuration.password ?? "")
        return try await send(types: [messageType]).message
    }

    @discardableResult
    private func send(types: [MessageType]) async throws -> Response {
        var messages = [Message]()
        let promise = channel.eventLoop.makePromise(of: Response.self)

        for type in types {
            var buffer = ByteBuffer()
            type.encode(into: &buffer)
            let message = Message(identifier: type.identifier, source: .frontend, buffer: buffer)
            messages.append(message)
        }

        let request = Request(messages: messages, promise: promise)
        try await channel.writeAndFlush(request).get()

        return try await promise.futureResult.get()
    }
}
