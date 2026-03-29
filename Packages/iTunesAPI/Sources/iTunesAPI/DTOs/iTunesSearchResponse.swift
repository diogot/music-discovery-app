public struct iTunesSearchResponse<Result: Decodable & Sendable>: Decodable, Sendable {
    public let resultCount: Int
    public let results: [Result]
}
