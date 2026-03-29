import Foundation
import NetworkService

public final class MockNetworkService: NetworkService, @unchecked Sendable {
    public private(set) var executedRequests: [Request] = []
    private let decoder: JSONDecoder
    private var responseData: Data?
    private var responseError: NetworkError?

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func setResponse<T: Encodable>(_ value: T, encoder: JSONEncoder = JSONEncoder()) {
        responseData = try? encoder.encode(value)
        responseError = nil
    }

    public func setResponse(_ data: Data) {
        responseData = data
        responseError = nil
    }

    public func setError(_ error: NetworkError) {
        responseError = error
        responseData = nil
    }

    public func execute<T: Decodable & Sendable>(_ request: Request) async throws -> T {
        executedRequests.append(request)

        if let error = responseError {
            throw error
        }

        guard let data = responseData else {
            fatalError("MockNetworkService: no response or error configured")
        }

        return try decoder.decode(T.self, from: data)
    }
}
