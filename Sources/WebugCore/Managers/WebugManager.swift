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
            let headers = Dictionary(uniqueKeysWithValues: req.headers.map { ($0.name, $0.value) })
            var d = req.body.data
            let readableBytes = d?.readableBytes ?? 0
            let payload = d?.readData(length: readableBytes) ?? Data()
            let entry = WebugEntry(
                groupId: group.id!,
                method: req.method.string,
                url: url,
                headers: headers,
                payload: payload
            )
            return entry.save(on: db).flatMap { entry in
                let client = HTTPClient(eventLoopGroupProvider: .shared(db.eventLoop))
                let request = try! HTTPClient.Request(
                    url: url,
                    method: req.method,
                    headers: req.headers,
                    body: HTTPClient.Body.data(payload)
                )
                return client.execute(
                    request: request
                ).flatMap { result in
                    do { try client.syncShutdown() } catch { }
                    
                    let body: Response.Body
                    let byteBuffer = result.body
                    if let readableBytes = byteBuffer?.readableBytes, readableBytes > 0, let byteBuffer = byteBuffer {
                        body = Response.Body(buffer: byteBuffer)
                    } else {
                        body = Response.Body(data: Data())
                    }
                    
                    let response = Response(
                        status: result.status,
                        headers: result.headers,
                        body: body
                    )
                    return db.eventLoop.makeSucceededFuture(response)
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
    
}
