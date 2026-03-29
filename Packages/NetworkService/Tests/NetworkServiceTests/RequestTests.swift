import Foundation
import Testing
@testable import NetworkService

@Suite("Request")
struct RequestTests {
    @Test("Default values: GET method, empty queryItems/headers, nil body")
    func defaultValues() {
        let request = Request(path: "/search")

        #expect(request.method == .get)
        #expect(request.path == "/search")
        #expect(request.queryItems.isEmpty)
        #expect(request.headers.isEmpty)
        #expect(request.body == nil)
    }

    @Test("Custom init stores all properties")
    func customInit() {
        let body = Data("test".utf8)
        let request = Request(
            method: .post,
            path: "/submit",
            queryItems: ["key": "value"],
            headers: ["Authorization": "Bearer token"],
            body: body
        )

        #expect(request.method == .post)
        #expect(request.path == "/submit")
        #expect(request.queryItems == ["key": "value"])
        #expect(request.headers == ["Authorization": "Bearer token"])
        #expect(request.body == body)
    }
}
