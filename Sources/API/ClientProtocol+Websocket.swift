//
//  ClientProtocol+Websocket.swift
//  TradeWithMe
//
//  Created by Szymon on 4/3/2022.
//

import Foundation

extension ClientProtocol {
    public func websocketRequest(path: String, searchParams: HTTPQueryParams? = nil) async throws -> URLRequest {
        let query = environment.setQueryParams(searchParams, api: environment.api.wss ?? "")
        var components = URLComponents(string: (environment.api.wss ?? "") + path)
        components?.queryItems = query?.compactMapValues { $0 }.map(URLQueryItem.init)
        
        guard let url = components?.url else {
            throw RequestError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("trade-with-me/1.0", forHTTPHeaderField: "User-Agent")
        return request
    }
}
