import Vapor


extension HTTPHeaders {
    
    func asDictionary() -> [String: String] {
        Dictionary(uniqueKeysWithValues: map { ($0.name, $0.value) })
    }
    
}
