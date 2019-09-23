import Fluent


public final class WebugEntry: Model, Content {
    
    public struct QueryParams: Decodable {
        public let url: String?
        public let search: String?
        public let group: String?
        public let limit: Int?
    }
    
    public struct Short: Content {
        public let id: Webug.DbIdType
        public let groupId: Webug.DbIdType
        public let requested: Date
        public let method: String
        public let url: String
        public let responded: Date?
        public let status: Int?
    }
    
    public static let schema = "webug"
    
    @ID(key: "id") public var id: Webug.DbIdType?

    @Field(key: "group_id") public var groupId: Webug.DbIdType
    @Field(key: "requested") public var requested: Date
    @Field(key: "method") public var method: String
    @Field(key: "url") public var url: String
    @Field(key: "request_headers") public var headers: [String: String]?
    @Field(key: "payload") public var payload: Data?
    @Field(key: "responded") public var responded: Date?
    @Field(key: "status") public var status: Int?
    @Field(key: "response_headers") public var responseHeaders: [String: String]?
    @Field(key: "body") public var body: Data?

    required public init() { }

    public init(
        id: Webug.DbIdType? = nil,
        groupId: Webug.DbIdType,
        requested: Date = Date(),
        method: String,
        url: String,
        headers: [String: String]? = nil,
        payload: Data? = nil,
        responded: Date? = nil,
        status: Int? = nil,
        responseHeaders: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.id = id
        self.groupId = groupId
        self.requested = requested
        self.method = method
        self.url = url
        self.headers = headers
        self.payload = payload
        self.responded = responded
        self.status = status
        self.responseHeaders = responseHeaders
        self.body = body
    }
    
}

public struct WebugEntryMigration: Migration {
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("webug")
            .field("id", .uuid, .identifier(auto: Webug.DbIdType.self == Int.self))
            .field("group_id", .uuid, .required)
            .field("requested", .date, .required)
            .field("method", .string, .required)
            .field("url", .string, .required)
            .field("request_headers", .json)
            .field("payload", .data)
            .field("responded", .date)
            .field("status", .int)
            .field("response_headers", .json)
            .field("body", .data)
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("webug").delete()
    }
    
}


extension Array where Element == WebugEntry {
    
    public func asShort() -> [WebugEntry.Short] {
        map({
            WebugEntry.Short(
                id: $0.id!,
                groupId: $0.groupId,
                requested: $0.requested,
                method: $0.method,
                url: $0.url,
                responded: $0.responded,
                status: $0.status
            )
        })
    }
    
}
