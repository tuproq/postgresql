public final class Result {
    let columns: [Column]
    public internal(set) var data = [[Column: Codable?]]()

    init(columns: [Column]) {
        self.columns = columns
    }
}
