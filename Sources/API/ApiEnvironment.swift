import Foundation

public struct API: Codable, Equatable {
    var http: String
    var wss: String? = nil
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

    func setHeaders(request: inout URLRequest) {}
}
