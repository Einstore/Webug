import Fluent


public protocol Controller {
    
    var db: Database { get }
    init(_ db: Database)
    func routes(_ r: Routes, _ c: Container) throws
    
}
