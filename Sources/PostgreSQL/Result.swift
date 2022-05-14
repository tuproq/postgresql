final class Result {
    let columns: [Column]
    var data = [[String: Codable?]]()

    init(columns: [Column]) {
        self.columns = columns
    }
}
