import Foundation

public protocol API {
    var baseURL: URL { get }
    var defaultHeaders: [String: String] { get }
}

public enum APIError: Swift.Error {
    case requestFailed
    case invalidResponse
    case invalidURL
    case decodingFailed
    case status(Int)
}

public extension API {
    func sendRequest<R: Request>(_ request: R) async throws -> R.Response {
        var components = URLComponents(string: "\(baseURL.absoluteString)\(request.path.isEmpty ? "" : request.path)")
        components?.queryItems = request.parameters?.compactMap { URLQueryItem(name: $0.key, value: $0.value) }

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        defaultHeaders.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        request.headers?.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        
        urlRequest.httpBody = request.body
        urlRequest.timeoutInterval = request.timeoutInterval

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard R.Response.self != VoidResponse.self else {
            return VoidResponse() as! R.Response
        }
        
        guard !data.isEmpty else { throw APIError.decodingFailed }
        guard let httpResponse = response as? HTTPURLResponse,
                (200 ..< 300).contains(httpResponse.statusCode) else {
            throw APIError.status((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        do {
            return try jsonDecoder.decode(R.Response.self, from: data)
        } catch let thrownError {
            throw thrownError
        }
    }
}
