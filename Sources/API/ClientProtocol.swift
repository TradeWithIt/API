import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public typealias HTTPQueryParams = [String: String?]

public typealias HTTPBodyParams = [String: Any?]

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case options = "OPTIONS"
}

public protocol ClientProtocol {
    associatedtype API: ApiEnvironment
    var environment: API { get }
    var timeoutInterval: TimeInterval { get }
}

// MARK: - Requests
let urlSession = URLSession(configuration: .ephemeral)

extension ClientProtocol {
    public func get<T>(_ urlPath: String, searchParams: HTTPQueryParams? = nil) async throws -> T where T: Decodable {
        return try await request(.get, urlPath: urlPath, searchParams: searchParams)
    }

    public func delete<T>(_ urlPath: String, searchParams: HTTPQueryParams? = nil) async throws -> T where T: Decodable {
        return try await request(.delete, urlPath: urlPath, searchParams: searchParams)
    }

    public func post<T>(_ urlPath: String, searchParams: HTTPQueryParams? = nil) async throws -> T where T: Decodable {
        return try await request(.post, urlPath: urlPath, searchParams: searchParams)
    }

    public func post<T, V>(_ urlPath: String, searchParams: HTTPQueryParams? = nil, body: V) async throws -> T where T: Decodable, V: Encodable {
        return try await request(.post, urlPath: urlPath, searchParams: searchParams, body: body)
    }

    public func post<T>(_ urlPath: String, searchParams: HTTPQueryParams? = nil, body: HTTPBodyParams) async throws -> T where T: Decodable {
        return try await request(.post, urlPath: urlPath, searchParams: searchParams, body: body)
    }

    public func put<T>(_ urlPath: String, searchParams: HTTPQueryParams? = nil) async throws -> T where T: Decodable {
        return try await request(.put, urlPath: urlPath, searchParams: searchParams)
    }

    public func put<T, V>(_ urlPath: String, searchParams: HTTPQueryParams? = nil, body: V) async throws -> T where T: Decodable, V: Encodable {
        return try await request(.put, urlPath: urlPath, searchParams: searchParams, body: body)
    }

    public func put<T>(_ urlPath: String, searchParams: HTTPQueryParams? = nil, body: HTTPBodyParams) async throws -> T where T: Decodable {
        return try await request(.put, urlPath: urlPath, searchParams: searchParams, body: body)
    }

    public func patch<T>(_ urlPath: String, searchParams: HTTPQueryParams? = nil) async throws -> T where T: Decodable {
        return try await request(.patch, urlPath: urlPath, searchParams: searchParams)
    }

    public func patch<T, V>(_ urlPath: String, searchParams: HTTPQueryParams? = nil, body: V) async throws -> T where T: Decodable, V: Encodable {
        return try await request(.patch, urlPath: urlPath, searchParams: searchParams, body: body)
    }

    public func patch<T>(_ urlPath: String, searchParams: HTTPQueryParams? = nil, body: HTTPBodyParams) async throws -> T where T: Decodable {
        return try await request(.patch, urlPath: urlPath, searchParams: searchParams, body: body)
    }

    public func request<T>(_ method: HTTPMethod, urlPath: String, searchParams: HTTPQueryParams? = nil) async throws -> T where T: Decodable {
        return try await request(method, urlPath: urlPath, searchParams: searchParams, httpBody: nil)
    }

    public func request<T, V>(_ method: HTTPMethod, urlPath: String, searchParams: HTTPQueryParams? = nil, body: V) async throws -> T where T: Decodable, V: Encodable {
        let data = try Utils.jsonEncoder.encode(body)
        return try await request(method, urlPath: urlPath, searchParams: searchParams, httpBody: data)
    }

    public func request<T>(_ method: HTTPMethod, urlPath: String, searchParams: HTTPQueryParams? = nil, body: HTTPBodyParams) async throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: body.compactMapValues { $0 }, options: [])
        return try await request(method, urlPath: urlPath, searchParams: searchParams, httpBody: data)
    }

    private func request<T>(_ method: HTTPMethod, urlPath: String, searchParams: HTTPQueryParams? = nil, httpBody: Data? = nil) async throws -> T where T: Decodable {
        let query = environment.setQueryParams(searchParams, api: environment.api.http)
        var components = URLComponents(string: "\(environment.api.http)\(urlPath)")
        components?.queryItems = query?.compactMapValues { $0 }.map(URLQueryItem.init)

        guard let url = components?.url else {
            throw RequestError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        environment.setHeaders(request: &request)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(environment.api.userAgent, forHTTPHeaderField: "User-Agent")
        request.httpBody = httpBody
        request.timeoutInterval = timeoutInterval

        let (data, response) = try await urlSession.data(for: request)
        guard !data.isEmpty else { throw RequestError.emptyData }
        guard let httpResponse = response as? HTTPURLResponse, 200 ..< 300 ~= httpResponse.statusCode else {
            print("🛑", (response as? HTTPURLResponse)?.statusCode ??  -1, String(data: data, encoding: .utf8) ?? "")
            throw RequestError.error((response as? HTTPURLResponse)?.statusCode ?? -1,
                                     try Utils.jsonDecoder.decode(ErrorMessage.self, from: data))
        }
        
        do {
            return try Utils.jsonDecoder.decode(T.self, from: data)
        } catch let thrownError {
            print("🛑", (response as? HTTPURLResponse)?.statusCode ??  -1, String(data: data, encoding: .utf8) ?? "", "\n\n", thrownError)
            throw thrownError
        }
    }
}
