import Foundation

public struct ErrorMessage: Decodable {
    public let message: String
}

public struct EmptyResponse: Decodable {
    internal static let jsonData = try! JSONSerialization.data(withJSONObject: [:], options: [])
}

public enum RequestError: Error {
    case invalidURL
    case status(Int)
    case error(Int, ErrorMessage)
}

public struct MultiResponse<T>: Codable where T: Codable {
    public let status: Int
    public let body: T
}

public enum SortDirection: String, Codable, CaseIterable {
    case asc = "asc"
    case desc = "desc"
}

public protocol StringRepresentable: CustomStringConvertible {
    init?(_ string: String)
}

extension Double: StringRepresentable {}

extension Float: StringRepresentable {}

extension Int: StringRepresentable {}

public struct NumericString<Value: StringRepresentable>: Codable {
    public var value: Value

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)

        guard let value = Value(string) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: """
                Failed to convert an instance of \(Value.self) from "\(string)"
                """
            )
        }

        self.value = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value.description)
    }
}

public enum Number: Codable, Hashable, CustomStringConvertible {
    public var percentDescription: String {
        return String(format: "%.2f%%", (self * 100).asDouble)
    }

    public var description: String {
        switch self {
        case .string(let string):
            return string
        case .double(let double):
            return String(double)
        case .int(let int):
            return String(int)
        }
    }
    
    var asString: String {
        switch self {
        case .double(let double):
            let formatter = NumberFormatter()
            let number = NSNumber(value: double)
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 4
            return String(formatter.string(from: number) ?? "")
        default:
            return self.description
        }
    }
    
    var asDouble: Double {
        switch self {
        case .string(let string):
            return Double(string) ?? .nan
        case .double(let double):
            return double
        case .int(let int):
            return Double(int)
        }
    }
    
    var asInt: Int {
        switch self {
        case .string(let string):
            return Int(string) ?? .zero
        case .double(let double):
            return Int(double)
        case .int(let int):
            return int
        }
    }
    
    case string(String)
    case double(Double)
    case int(Int)
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(asString)
    }
    
    public init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }
        if let double = try? decoder.singleValueContainer().decode(Double.self) {
            self = .double(double)
            return
        }
        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }
        let context = EncodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode type")
        throw EncodingError.invalidValue(decoder.userInfo, context)
    }
}

// MARK: Number operators overload

extension Number {
    static func * (left: Number, right: Double) -> Number {
        switch left {
        case .string(let string):
            if let double = Double(string) {
                return .double(double * right)
            } else if let int = Int(string) {
                return .int(int * Int(right))
            }
            return left
        case .double(let double):
            return .double(double * right)
        case .int(let int):
            return .int(int * Int(right))
        }
    }

    static func * (left: Number, right: Int) -> Number {
        switch left {
        case .string(let string):
            if let double = Double(string) {
                return .double(double * Double(right))
            } else if let int = Int(string) {
                return .int(int * right)
            }
            return left
        case .double(let double):
            return .double(double * Double(right))
        case .int(let int):
            return .int(int * right)
        }
    }
    
    static func / (left: Number, right: Double) -> Number {
        switch left {
        case .string(let string):
            if let double = Double(string) {
                return .double(double / right)
            } else if let int = Int(string) {
                return .int(int / Int(right))
            }
            return left
        case .double(let double):
            return .double(double / right)
        case .int(let int):
            return .int(int / Int(right))
        }
    }

    static func / (left: Number, right: Int) -> Number {
        switch left {
        case .string(let string):
            if let double = Double(string) {
                return .double(double / Double(right))
            } else if let int = Int(string) {
                return .int(int / right)
            }
            return left
        case .double(let double):
            return .double(double / Double(right))
        case .int(let int):
            return .int(int / right)
        }
    }
}
