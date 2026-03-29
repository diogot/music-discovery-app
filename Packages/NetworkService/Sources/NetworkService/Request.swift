import Foundation

public struct Request: Sendable {
    public let method: HTTPMethod
    public let path: String
    public let queryItems: [String: String?]
    public let headers: [String: String]
    public let body: Data?

    public init(
        method: HTTPMethod = .get,
        path: String,
        queryItems: [String: String?] = [:],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.method = method
        self.path = path
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
}
