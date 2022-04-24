import Foundation

public struct API: Codable, Equatable {
    public var http: String
    public var wss: String?
    
    public init(http: String, wss: String? = nil) {
        self.http = http
        self.wss = wss
    }
}

public protocol ApiEnvironment {
    var api: API { get }
    var key: String { get }
    var secret: String { get }
    func setQueryParams(_ query: HTTPQueryParams?, api: String) -> HTTPQueryParams?
    func setHeaders(request: inout URLRequest)
}

extension ApiEnvironment {
    public func setQueryParams(_ query: HTTPQueryParams?, api: String) -> HTTPQueryParams? {
        return query
    }

    public func setHeaders(request: inout URLRequest) {}
}
