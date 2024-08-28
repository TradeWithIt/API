import Foundation

public protocol Request {
    associatedtype Response: Decodable
    
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: String]? { get }
    var body: Data? { get }
    var timeoutInterval: TimeInterval { get }
}

public extension Request {
    var headers: [String: String]? { nil }
    var parameters: [String: String]? { nil }
    var body: Data? { nil }
    var timeoutInterval: TimeInterval { TimeInterval(10) }
}
