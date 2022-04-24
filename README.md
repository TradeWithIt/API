# API

Simple HTTP and WSS client build on top of Swift Foundation URLSesison.

HTTP example:

```swift
    public func balance(coin: String? = nil) async throws -> BybitPublic<[String: BybitCoin]> {
        return try await get("/v2/private/wallet/balance", searchParams: ["coin": coin])
    }
```

Websocket example:

```swift
var request = URLRequest(url: url)
try websocketPublic.connect(to: request, {[weak self] ws in
    ws.onText { ws, text in
        guard let self = self else { return }
        self.updatePublicData(text, symbol: symbol, interval: self.interval, bybit: bybit)

    }
    ws.onClose { ws in }
    self?.subscribePublicWss()
})
```

It comes with some basic utilities which make life easier.
