import Foundation
import Testing
@testable import NetworkService

@Suite("NetworkError Equatable")
struct NetworkErrorTests {
    @Test("Same cases are equal")
    func sameCasesEqual() {
        #expect(NetworkError.invalidURL == NetworkError.invalidURL)
        #expect(NetworkError.noInternet == NetworkError.noInternet)
    }

    @Test("Different cases are not equal")
    func differentCasesNotEqual() {
        #expect(NetworkError.invalidURL != NetworkError.noInternet)
        #expect(NetworkError.noInternet != NetworkError.invalidURL)

        let data = Data("error".utf8)
        #expect(NetworkError.requestFailed(statusCode: 404, data: data) != NetworkError.noInternet)
    }

    @Test("requestFailed: same statusCode and data are equal")
    func requestFailedEqual() {
        let data = Data("not found".utf8)
        #expect(
            NetworkError.requestFailed(statusCode: 404, data: data) ==
            NetworkError.requestFailed(statusCode: 404, data: data)
        )
    }

    @Test("requestFailed: different statusCode are not equal")
    func requestFailedDifferentStatusCode() {
        let data = Data("error".utf8)
        #expect(
            NetworkError.requestFailed(statusCode: 404, data: data) !=
            NetworkError.requestFailed(statusCode: 500, data: data)
        )
    }

    @Test("requestFailed: different data are not equal")
    func requestFailedDifferentData() {
        #expect(
            NetworkError.requestFailed(statusCode: 404, data: Data("a".utf8)) !=
            NetworkError.requestFailed(statusCode: 404, data: Data("b".utf8))
        )
    }
}
