public struct CollectionDTO: Decodable, Sendable, Equatable {
    public let collectionId: Int
    public let collectionName: String
    public let artistName: String
    public let artistId: Int
    public let artworkUrl100: String?
    public let trackCount: Int
    public let releaseDate: String?
    public let primaryGenreName: String?
    public let copyright: String?
}
