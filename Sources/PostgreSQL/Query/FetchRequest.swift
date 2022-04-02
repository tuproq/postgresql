import NIOCore

final class FetchRequest {
    var columns: [Column]
    var result: [[String: Codable?]] = .init()

    init(columns: [Column]) {
        self.columns = columns
    }
}
