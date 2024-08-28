# API

Simple HTTP and WSS client build on top of Swift Foundation URLSesison.


## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, adding a dependency is as easy as adding it to the dependencies value of your Package.swift.

```
dependencies: [
    .package(url: "https://github.com/TradeWithIt/API", branch: "main")
]
```

## Usage 

```swift
import API

let client = MyAPIClient(baseURL: url)
let response = try await client.login(googleToken: token)
```

HTTP example:

```swift
import API

public struct MyAPIClient: API {
    public var accessToken: String?
    public var baseURL: URL
    
    public init(accessToken: String? = nil, baseURL: URL) {
        self.accessToken = accessToken
        self.baseURL = baseURL
    }
    
    public var defaultHeaders: [String : String] {
        [
            "Authorization": "Bearer \(accessToken ?? "")",
            "Content-Type": "application/json"
        ]
    }
}
```

Request example:

```swift
import API

enum AuthenticationRequest: Request {
    typealias Response = AccountResponse

    case postMagicLink(email: String)
    case getMagicLink(token: String)
    case postAppleLogin(firstName: String?, lastName: String?, appleIdentityToken: String)
    case postGoogleLogin(accessToken: String)

    var path: String {
        switch self {
        case .postMagicLink:
            return "/auth/magic-link"
        case .getMagicLink:
            return "/auth/magic-link"
        case .postAppleLogin:
            return "/auth/apple"
        case .postGoogleLogin:
            return "/auth/google"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .postMagicLink, .postAppleLogin, .postGoogleLogin:
            return .post
        case .getMagicLink:
            return .get
        }
    }

    var body: Data? {
        do {
            switch self {
            case .postMagicLink(let email):
                return try jsonEncoder.encode(MagicLinkRequestBody(email: email))
            case .postAppleLogin(let firstName, let lastName, let appleIdentityToken):
                return try jsonEncoder.encode(SIWARequestBody(firstName: firstName, lastName: lastName, appleIdentityToken: appleIdentityToken))
            case .postGoogleLogin(let accessToken):
                return try jsonEncoder.encode(GoogleRequestBody(accessToken: accessToken))
            default:
                return nil
            }
        } catch {
            print("🔴", error)
        }
        return nil
    }
}

// MARK: Endpoints

extension MyAPIClient {
    public func requestLink(email: String) async throws {
        _ = try await sendRequest(AuthenticationRequest.postMagicLink(email: email))
    }
    
    public func login(token: String) async throws -> AccountResponse {
        try await sendRequest(AuthenticationRequest.getMagicLink(token: token))
    }
    
    public func login(firstName: String?, lastName: String?, appleIdentityToken: String) async throws -> AccountResponse {
        try await sendRequest(AuthenticationRequest.postAppleLogin(firstName: firstName, lastName: lastName, appleIdentityToken: appleIdentityToken))
    }
    
    public func login(googleToken: String) async throws -> AccountResponse {
        try await sendRequest(AuthenticationRequest.postGoogleLogin(accessToken: googleToken))
    }
}

// MARK: Types

struct MagicLinkRequestBody: Encodable {
    let email: String
}

struct SIWARequestBody: Encodable {
    let firstName: String?
    let lastName: String?
    let appleIdentityToken: String
}

struct GoogleRequestBody: Encodable {
    let accessToken: String
}

```

It comes with some basic utilities which make life easier.
