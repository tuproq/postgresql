import NIOCore

final class FetchRequest {
    var columns: [String]
    var result: [[String: Any?]] = .init()

    init(columns: [String] = .init()) {
        self.columns = columns
    }
}
