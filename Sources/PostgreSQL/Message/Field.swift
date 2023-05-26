extension Message {
    enum Field: UInt8 {
        case localizedSeverity = 0x53 /// S
        case severity = 0x56 /// V
        case code = 0x43 /// C
        case message = 0x4D /// M
        case detail = 0x44 /// D
        case hint = 0x48 /// H
        case position = 0x50 /// P
        case internalPosition = 0x70 /// p
        case internalQuery = 0x71 /// q
        case `where` = 0x57 /// W
        case schemaName = 0x73 /// s
        case tableName = 0x74 /// t
        case columnName = 0x63 /// c
        case dataTypeName = 0x64 /// d
        case constraintName = 0x6E /// n
        case file = 0x46 /// F
        case line = 0x4C /// L
        case routine = 0x52 /// R
    }
}
