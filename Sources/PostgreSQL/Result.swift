final class Result {
    var columns: [Column]
    var data = [[String: Codable?]]()

    init(columns: [Column]) {
        self.columns = columns
    }
}
