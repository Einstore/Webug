import Vapor
import Fluent
import AsyncHTTPClient


class WebugManager {
    
    public enum Error: Swift.Error {
        case missingUrl
    }
    
    static func fetch(request req: Request, on db: Database) -> EventLoopFuture<Response> {
        guard let params = try? req.query.decode(WebugEntry.QueryParams.self), let url = params.url else {
            return req.eventLoop.makeFailedFuture(Error.missingUrl)
        }
        return guaranteed(group: params.group, on: db).flatMap { group in
            var d = req.body.data
            let readableBytes = d?.readableBytes ?? 0
            let payload = d?.readData(length: readableBytes)
            let entry = WebugEntry(
                group_id: group.id!,
                method: req.method.string,
                url: url,
                headers: req.headers.asDictionary(),
                payload: payload
            )
            return entry.save(on: db).flatMap { _ in
                let client = HTTPClient(eventLoopGroupProvider: .shared(db.eventLoop))
                let request = try! HTTPClient.Request(
                    url: url,
                    method: req.method,
                    headers: [:],
                    body: HTTPClient.Body.data(payload ?? Data())
                )
                return client.execute(
                    request: request
                ).flatMap { result in
                    do { try client.syncShutdown() } catch { }
                    
                    entry.responded = Date()
                    
                    let body: Response.Body
                    let byteBuffer = result.body
                    if let readableBytes = byteBuffer?.readableBytes, readableBytes > 0, var byteBuffer = byteBuffer {
                        body = Response.Body(buffer: byteBuffer)
                        entry.body = byteBuffer.readData(length: readableBytes)
                    } else {
                        body = Response.Body(data: Data())
                    }
                    
                    entry.status = Int(result.status.code)
                    entry.response_headers = result.headers.asDictionary()
                    return entry.save(on: db).map { _ in
                        let response = Response(
                            status: result.status,
                            headers: result.headers,
                            body: body
                        )
                        return response
                    }
                }
            }
        }
    }
    
    static func guaranteed(group name: String?, on db: Database) -> EventLoopFuture<WebugGroup> {
        let name = name ?? "global"
        return WebugGroup.query(on: db).filter(\WebugGroup.$name == name).first().flatMap { group in
            guard let group = group else {
                let group = WebugGroup(name: name)
                return group.save(on: db).map { _ in
                    return group
                }
            }
            return db.eventLoop.makeSucceededFuture(group)
        }
    }
    
    private static func recusive(name: String, for group: WebugGroup, on db: Database) -> EventLoopFuture<String> {
        return WebugGroup.query(on: db).filter(\WebugGroup.$name == name).first().flatMap { g in
            guard g == nil else {
                return recusive(name: String(group.id!.uuidString.prefix((name.count + 1))), for: group, on: db)
            }
            return db.eventLoop.makeSucceededFuture(name)
        }
    }
    
    static func new(on db: Database) -> EventLoopFuture<WebugGroup> {
        return guaranteed(group: UUID().uuidString, on: db).flatMap { group in
            return recusive(name: String(group.id!.uuidString.prefix(3)), for: group, on: db).flatMap { name in
                group.auto = true
                group.name = name
                return group.save(on: db).map { _ in
                    return group
                }
            }
        }
    }
    
}
