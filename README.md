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
