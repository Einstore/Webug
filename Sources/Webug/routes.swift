import WebugCore


/// Register your application's routes here.
public func routes(_ r: Routes, _ c: Container) throws {
    try Webug.configure(routes: r, on: c)
}
