extension RawRepresentable where Self: PostgreSQLCodable {
    public static var psqlFormat: DataFormat { .text }
    public static var psqlType: DataType { .text }
}
