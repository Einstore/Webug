import Vapor
import WebugCore


/// Called before your application initializes.
public func configure(_ s: inout Services) throws {
    /// Register routes
    s.extend(Routes.self) { r, c in
        try routes(r, c)
    }

    /// Register middleware
    s.register(MiddlewareConfiguration.self) { c in
        // Create _empty_ middleware config
        var middlewares = MiddlewareConfiguration()
        
        // Serves files from `Public/` directory
        /// middlewares.use(FileMiddleware.self)
        
        middlewares.use(
            CORSMiddleware(
                configuration: CORSMiddleware.Configuration(
                    allowedOrigin: .all,
                    allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
                    allowedHeaders: []
                )
            )
        )
        
        // Catches errors and converts to HTTP response
        try middlewares.use(c.make(ErrorMiddleware.self))
        
        return middlewares
    }
    
    let dbId = try Webug.setup(database: &s)
    
    s.register(Migrations.self) { c in
        var migrations = Migrations()
        try Webug.configure(migrations: &migrations, dbIdentifier: dbId)
        return migrations
    }
    
    try Webug.configure(services: &s)
}
