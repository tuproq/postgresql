public final class Result {
    public let columns: [Column]
    public internal(set) var rows = [[Any?]]()

    init(columns: [Column]) {
        self.columns = columns
    }
}
