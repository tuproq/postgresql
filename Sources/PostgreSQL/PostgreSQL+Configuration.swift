import Foundation

extension PostgreSQL {
    public struct Configuration: Equatable {
        public static let defaultIdentifier = "dev.tuproq.postgresql"
        public static let defaultHost = "127.0.0.1"
        public static let defaultPort = 5432

        public var identifier: String
        public var host: String
        public var port: Int
        public var username: String?
        public var password: String?
        public var database: String?
        public var requiresTLS: Bool

        public init(
            identifier: String = defaultIdentifier,
            host: String = defaultHost,
            port: Int = defaultPort,
            username: String? = nil,
            password: String? = nil,
            database: String? = nil,
            requiresTLS: Bool = false
        ) {
            self.identifier = identifier
            self.host = host
            self.port = port
            self.username = username
            self.password = password
            self.database = database
            self.requiresTLS = requiresTLS
        }

        public init?(
            identifier: String = defaultIdentifier,
            url: URL,
            requiresTLS: Bool = false
        ) {
            guard
                let urlComponents = URLComponents(string: url.absoluteString),
                let driver = urlComponents.scheme, (driver == "postgresql" || driver == "postgres") else { return nil }
            self.identifier = identifier

            if let host = urlComponents.host, !host.isEmpty {
                self.host = host
            } else {
                host = Configuration.defaultHost
            }

            port = urlComponents.port ?? Configuration.defaultPort
            username = urlComponents.user
            password = urlComponents.password
            self.requiresTLS = requiresTLS
            let database = urlComponents.path.droppingLeadingSlash

            if !database.isEmpty {
                self.database = database
            }
        }
    }
}
