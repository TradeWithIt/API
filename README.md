# API

Simple HTTP and WSS client build on top of Swift Foundation URLSesison.

example:

```swift
    public func balance(coin: String? = nil) async throws -> BybitPublic<[String: BybitCoin]> {
        return try await get("/v2/private/wallet/balance", searchParams: ["coin": coin])
    }
```

It comes with some basic utilities which make life easier.
