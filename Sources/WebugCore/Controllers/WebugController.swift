import Fluent


class WebugController: Controller {
    
    let maxLimit = 500
    
    public enum Error: Swift.Error {
        case notFound
    }
    
    let db: Database
    
    required init(_ db: Database) {
        self.db = db
    }
    
    func routes(_ r: Routes, _ c: Container) throws {
        r.get("fetch") { req -> EventLoopFuture<Response> in
            return WebugManager.fetch(request: req, on: self.db)
        }
        r.post("fetch") { req -> EventLoopFuture<Response> in
            return WebugManager.fetch(request: req, on: self.db)
        }
        r.put("fetch") { req -> EventLoopFuture<Response> in
            return WebugManager.fetch(request: req, on: self.db)
        }
        r.patch("fetch") { req -> EventLoopFuture<Response> in
            return WebugManager.fetch(request: req, on: self.db)
        }
        r.delete("fetch") { req -> EventLoopFuture<Response> in
            return WebugManager.fetch(request: req, on: self.db)
        }
        r.on(.OPTIONS, ["fetch"]) { req -> EventLoopFuture<Response> in
            return WebugManager.fetch(request: req, on: self.db)
        }
        
        r.get("requests") { req -> EventLoopFuture<[WebugEntry.Short]> in
            var q = WebugEntry.query(on: self.db).sort(\WebugEntry.$requested, .descending)
            if let params = try? req.query.decode(WebugEntry.QueryParams.self) {
                if let search = params.search {
                    q = q.filter(\WebugEntry.$url == search)
                }
                if let group = params.group {
                    return WebugGroup.query(on: self.db).filter(\WebugGroup.$name == group).first().flatMap { group in
                        guard let groupId = group?.id else {
                            return c.eventLoop.makeFailedFuture(Error.notFound)
                        }
                        q = q.filter(\WebugEntry.$group_id == groupId)
                        return q.limit(params.limit ?? self.maxLimit).all().map { entries in
                            entries.asShort()
                        }
                    }
                }
            } else {
                q = q.limit(self.maxLimit)
            }
            return q.all().map { entries in
                entries.asShort()
            }
        }
        
        r.get("requests", ":id_request") { req -> EventLoopFuture<WebugEntry> in
            guard let entryId = req.parameters.get("id_request", as: Webug.DbIdType.self) else {
                throw Error.notFound
            }
            return WebugEntry.query(on: self.db).filter(\WebugEntry.$id == entryId).first().flatMapThrowing { entry in
                guard let entry = entry else {
                    throw Error.notFound
                }
                return entry
            }
        }
        
        r.get("groups") { req -> EventLoopFuture<[WebugGroup]> in
            let q = WebugGroup.query(on: self.db).sort(\WebugGroup.$name, .ascending)
            return q.all()
        }
        
        r.get("groups", "new") { req -> EventLoopFuture<WebugGroup> in
            return WebugManager.new(on: self.db)
        }
        
        r.delete("groups", ":id_group") { req -> EventLoopFuture<Response> in
            guard let groupId = req.parameters.get("id_group", as: Webug.DbIdType.self) else {
                throw Error.notFound
            }
            return WebugGroup.query(on: self.db).filter(\WebugGroup.$id == groupId).first().flatMap { group in
                guard let group = group else {
                    return c.eventLoop.makeFailedFuture(Error.notFound)
                }
                return group.delete(on: self.db).map { _ in
                    return Response(status: .noContent, headers: [:])
                }
            }
        }
    }
    
}

