import Fluent


public final class WebugEntry: Model, Content {
    
    public static let schema = "webug"
    
    @ID(key: "id") public var id: Int?

    @Field(key: "title") public var title: String

    required public init() { }

    public init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
    }
    
}

public struct WebugEntryMigration: Migration {
    
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("webug")
            .field("id", .int, .identifier(auto: true))
            .field("title", .string, .required)
            .create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("webug").delete()
    }
    
}
