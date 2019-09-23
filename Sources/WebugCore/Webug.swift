import Fluent
import Redis


public class Webug {
    
    public typealias DbIdType = UUID
    
    static let controllers: [Controller.Type] = [
        WebugController.self
    ]
    
    public static func configure(services s: inout Services) throws {
//        s.provider(RedisClient())
    }
    
    public static func configure(migrations: inout Migrations, dbIdentifier: DatabaseID) throws {
        migrations.add(WebugEntryMigration(), to: dbIdentifier)
        migrations.add(WebugGroupMigration(), to: dbIdentifier)
    }
    
    public static func configure(routes r: Routes, on c: Container, db: Database? = nil) throws {
        let db: Database = try db ?? c.make()
        
        for controllerType in controllers {
            let controller = controllerType.init(db)
            try controller.routes(r, c)
        }
    }
    
}


extension Webug.DbIdType: LosslessStringConvertible {
    public init?(_ description: String) {
        self.init(uuidString: description)
    }
}
