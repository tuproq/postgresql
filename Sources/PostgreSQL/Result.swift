public final class Result {
    let columns: [Column]
    public internal(set) var data = [[String: Any?]]()

    init(columns: [Column]) {
        self.columns = columns
    }
}
