public enum DataType: Int32, CustomStringConvertible, Equatable {
    case null = 0
    case bool = 16
    case bytea = 17
    case char = 18
    case name = 19
    case int8 = 20
    case int2 = 21
    case int4 = 23
    case regproc = 24
    case text = 25
    case oid = 26
    case json = 114
    case pgNodeTree = 194
    case point = 600
    case float4 = 700
    case float8 = 701
    case money = 790
    case boolArray = 1000
    case byteaArray = 1001
    case charArray = 1002
    case nameArray = 1003
    case int2Array = 1005
    case int4Array = 1007
    case textArray = 1009
    case varcharArray = 1015
    case int8Array = 1016
    case pointArray = 1017
    case float4Array = 1021
    case float8Array = 1022
    case aclitemArray = 1034
    case bpchar = 1042
    case varchar = 1043
    case date = 1082
    case time = 1083
    case timestamp = 1114
    case timestampArray = 1115
    case timestamptz = 1184
    case timetz = 1266
    case numeric = 1700
    case void = 2278
    case uuid = 2950
    case uuidArray = 2951
    case jsonb = 3802
    case jsonbArray = 3807

    public var description: String { String(rawValue) }
}
