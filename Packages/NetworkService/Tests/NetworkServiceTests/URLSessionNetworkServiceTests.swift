import Foundation
import Testing
@testable import NetworkService

@Suite("URLSessionNetworkService", .serialized)
struct URLSessionNetworkServiceTests {
    @Test("Successful decode with 200 and valid JSON")
    func successfulDecode() async throws {
        let service = makeService()
        let expected = TestResponse(message: "hello")

        MockURLProtocol.requestHandler = { request in
            successResponse(url: request.url!, json: try JSONEncoder().encode(expected))
        }

        let result: TestResponse = try await service.execute(Request(path: "/test"))
        #expect(result == expected)
    }

    @Test("URL construction: path and query items appended, sorted alphabetically")
    func urlConstruction() async throws {
        let service = makeService()
        var capturedURL: URL?

        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            return successResponse(
                url: request.url!,
                json: try JSONEncoder().encode(TestResponse(message: "ok"))
            )
        }

        let _: TestResponse = try await service.execute(
            Request(path: "/search", queryItems: ["zebra": "z", "alpha": "a"])
        )

        let url = try #require(capturedURL)
        #expect(url.absoluteString == "https://api.example.com/search?alpha=a&zebra=z")
    }

    @Test("Nil query values are filtered out")
    func nilQueryValuesFiltered() async throws {
        let service = makeService()
        var capturedURL: URL?

        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            return successResponse(
                url: request.url!,
                json: try JSONEncoder().encode(TestResponse(message: "ok"))
            )
        }

        let _: TestResponse = try await service.execute(
            Request(path: "/search", queryItems: ["term": "test", "empty": nil])
        )

        let url = try #require(capturedURL)
        #expect(url.absoluteString == "https://api.example.com/search?term=test")
    }

    @Test("HTTP method set correctly on URLRequest")
    func httpMethodSet() async throws {
        let service = makeService()
        var capturedMethod: String?

        MockURLProtocol.requestHandler = { request in
            capturedMethod = request.httpMethod
            return successResponse(
                url: request.url!,
                json: try JSONEncoder().encode(TestResponse(message: "ok"))
            )
        }

        let _: TestResponse = try await service.execute(
            Request(method: .post, path: "/submit")
        )

        #expect(capturedMethod == "POST")
    }

    @Test("Custom headers appear on outgoing request")
    func customHeaders() async throws {
        let service = makeService()
        var capturedHeaders: [String: String]?

        MockURLProtocol.requestHandler = { request in
            capturedHeaders = request.allHTTPHeaderFields
            return successResponse(
                url: request.url!,
                json: try JSONEncoder().encode(TestResponse(message: "ok"))
            )
        }

        let _: TestResponse = try await service.execute(
            Request(path: "/test", headers: ["X-Custom": "value"])
        )

        #expect(capturedHeaders?["X-Custom"] == "value")
    }

    @Test("Body is set on URLRequest")
    func bodySet() async throws {
        let service = makeService()
        let bodyData = Data("{\"key\":\"value\"}".utf8)
        var capturedBody: Data?

        MockURLProtocol.requestHandler = { request in
            capturedBody = request.httpBody ?? request.httpBodyStream.flatMap { stream in
                stream.open()
                defer { stream.close() }
                var data = Data()
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
                defer { buffer.deallocate() }
                while stream.hasBytesAvailable {
                    let count = stream.read(buffer, maxLength: 1024)
                    if count > 0 { data.append(buffer, count: count) }
                }
                return data
            }
            return successResponse(
                url: request.url!,
                json: try JSONEncoder().encode(TestResponse(message: "ok"))
            )
        }

        let _: TestResponse = try await service.execute(
            Request(method: .post, path: "/submit", body: bodyData)
        )

        #expect(capturedBody == bodyData)
    }

    @Test("notConnectedToInternet URLError maps to .noInternet")
    func notConnectedToInternet() async {
        let service = makeService()

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        await #expect(throws: NetworkError.noInternet) {
            let _: TestResponse = try await service.execute(Request(path: "/test"))
        }
    }

    @Test("networkConnectionLost URLError maps to .noInternet")
    func networkConnectionLost() async {
        let service = makeService()

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.networkConnectionLost)
        }

        await #expect(throws: NetworkError.noInternet) {
            let _: TestResponse = try await service.execute(Request(path: "/test"))
        }
    }

    @Test("HTTP 404 throws .requestFailed")
    func http404() async {
        let service = makeService()
        let errorData = Data("not found".utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, errorData)
        }

        await #expect(throws: NetworkError.requestFailed(statusCode: 404, data: errorData)) {
            let _: TestResponse = try await service.execute(Request(path: "/missing"))
        }
    }

    @Test("HTTP 500 throws .requestFailed")
    func http500() async {
        let service = makeService()
        let errorData = Data("server error".utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, errorData)
        }

        await #expect(throws: NetworkError.requestFailed(statusCode: 500, data: errorData)) {
            let _: TestResponse = try await service.execute(Request(path: "/error"))
        }
    }

    @Test("Malformed JSON throws .decodingFailed")
    func malformedJSON() async {
        let service = makeService()

        MockURLProtocol.requestHandler = { request in
            successResponse(url: request.url!, json: Data("not json".utf8))
        }

        await #expect {
            let _: TestResponse = try await service.execute(Request(path: "/test"))
        } throws: { error in
            guard let networkError = error as? NetworkError,
                  case .decodingFailed = networkError else {
                return false
            }
            return true
        }
    }

    @Test("Unknown URLSession error maps to .unknown")
    func unknownError() async {
        let service = makeService()

        MockURLProtocol.requestHandler = { _ in
            throw URLError(.timedOut)
        }

        await #expect {
            let _: TestResponse = try await service.execute(Request(path: "/test"))
        } throws: { error in
            guard let networkError = error as? NetworkError,
                  case .unknown = networkError else {
                return false
            }
            return true
        }
    }
}

// MARK: - Test Helpers

private struct TestResponse: Codable, Sendable, Equatable {
    let message: String
}

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override static func canInit(with request: URLRequest) -> Bool { true }
    override static func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            fatalError("MockURLProtocol.requestHandler not set")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private func makeService(baseURL: String = "https://api.example.com") -> URLSessionNetworkService {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSessionNetworkService(
        baseURL: URL(string: baseURL)!,
        session: URLSession(configuration: config)
    )
}

private func successResponse(url: URL, json: Data, statusCode: Int = 200) -> (HTTPURLResponse, Data) {
    let response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    return (response, json)
}
