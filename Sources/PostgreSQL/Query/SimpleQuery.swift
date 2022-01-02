import NIOCore

final class SimpleQuery {
    var columns: [String]
    var rows: [[Any?]]

    init(columns: [String] = .init(), rows: [[Any?]] = .init()) {
        self.columns = columns
        self.rows = rows
    }
}
