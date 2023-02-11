public final class Result {
    public let columns: [Column]
    public internal(set) var rows = [[Decodable?]]()

    init(columns: [Column]) {
        self.columns = columns
    }
}
