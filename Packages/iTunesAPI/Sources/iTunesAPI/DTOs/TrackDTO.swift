import Foundation

public struct TrackDTO: Decodable, Sendable, Equatable {
    public let trackId: Int
    public let trackName: String
    public let artistName: String
    public let artistId: Int
    public let collectionId: Int
    public let collectionName: String
    public let trackNumber: Int
    public let trackCount: Int
    public let discNumber: Int
    public let discCount: Int
    public let trackTimeMillis: Int?
    public let previewUrl: URL?
    public let artworkUrl100: URL?
    public let releaseDate: String?
    public let primaryGenreName: String?
}
