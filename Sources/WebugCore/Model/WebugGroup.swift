import Fluent


public final class WebugGroup: Model, Content {
    
    public static let schema = "webug_group"
    
    @ID(key: "id") public var id: Webug.DbIdType?

    @Field(key: "name") public var name: String

    required public init() { }

    public init(id: Webug.DbIdType? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
}

public struct WebugGroupMigration: Migration {
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(WebugGroup.schema)
            .field("id", .uuid, .identifier(auto: Webug.DbIdType.self == Int.self))
            .field("name", .string, .required)
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema(WebugGroup.schema).delete()
    }
    
}
