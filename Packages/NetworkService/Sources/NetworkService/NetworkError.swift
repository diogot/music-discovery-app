import Foundation

public enum NetworkError: Error, Sendable {
    case invalidURL
    case noInternet
    case requestFailed(statusCode: Int, data: Data)
    case decodingFailed(Error)
    case unknown(Error)
}

extension NetworkError: Equatable {
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.noInternet, .noInternet):
            return true
        case let (.requestFailed(lhsCode, lhsData), .requestFailed(rhsCode, rhsData)):
            return lhsCode == rhsCode && lhsData == rhsData
        case let (.decodingFailed(lhsError), .decodingFailed(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.unknown(lhsError), .unknown(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
