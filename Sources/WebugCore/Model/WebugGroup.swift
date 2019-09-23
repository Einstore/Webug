import Fluent


public final class WebugGroup: Model, Content {
    
    public static let schema = "webug_group"
    
    @ID(key: "id") public var id: Webug.DbIdType?

    @Field(key: "name") public var name: String
    
    /// Group created by the API for future use
    ///     - Note: Auto generated groups won't show groups list by default
    @Field(key: "auto") public var auto: Bool

    required public init() { }

    public init(id: Webug.DbIdType? = nil, name: String, auto: Bool = false) {
        self.id = id
        self.name = name
        self.auto = auto
    }
    
}

public struct WebugGroupMigration: Migration {
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("webug_group")
            .field("id", .uuid, .identifier(auto: Webug.DbIdType.self == Int.self))
            .field("name", .string, .required)
            .field("auto", .bool, .required)
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("webug_group").delete()
    }
    
}
