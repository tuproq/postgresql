import NIOCore

final class FetchResult {
    var columns: [String]
    var result: [[String: Any?]] = .init()

    init(columns: [String] = .init()) {
        self.columns = columns
    }
}
