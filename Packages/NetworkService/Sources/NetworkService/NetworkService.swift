import Foundation

public protocol NetworkService: Sendable {
    func execute<T: Decodable & Sendable>(_ request: Request) async throws -> T
}

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
}
