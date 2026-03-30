import Foundation
import SwiftData

@Model
public final class Song {

    @Attribute(.unique)
    public var trackId: Int

    public var trackName: String
    public var artistName: String
    public var artistId: Int
    public var collectionId: Int
    public var collectionName: String
    public var trackNumber: Int
    public var discNumber: Int
    public var discCount: Int
    public var trackCount: Int
    public var trackTimeMillis: Int?
    public var previewURL: URL?
    public var artworkURL: URL?
    public var releaseDate: Date?
    public var genre: String?
    public var lastPlayedAt: Date?
    public var isLiked: Bool

    public init(
        trackId: Int,
        trackName: String,
        artistName: String,
        artistId: Int,
        collectionId: Int,
        collectionName: String,
        trackNumber: Int = 0,
        discNumber: Int = 1,
        discCount: Int = 1,
        trackCount: Int = 0,
        trackTimeMillis: Int? = nil,
        previewURL: URL? = nil,
        artworkURL: URL? = nil,
        releaseDate: Date? = nil,
        genre: String? = nil,
        lastPlayedAt: Date? = nil,
        isLiked: Bool = false
    ) {
        self.trackId = trackId
        self.trackName = trackName
        self.artistName = artistName
        self.artistId = artistId
        self.collectionId = collectionId
        self.collectionName = collectionName
        self.trackNumber = trackNumber
        self.discNumber = discNumber
        self.discCount = discCount
        self.trackCount = trackCount
        self.trackTimeMillis = trackTimeMillis
        self.previewURL = previewURL
        self.artworkURL = artworkURL
        self.releaseDate = releaseDate
        self.genre = genre
        self.lastPlayedAt = lastPlayedAt
        self.isLiked = isLiked
    }

    // MARK: - Computed Properties

    public var durationSeconds: TimeInterval? {
        guard let trackTimeMillis else { return nil }
        return TimeInterval(trackTimeMillis) / 1000.0
    }

    public var artworkLargeURL: URL? {
        guard let artworkURL else { return nil }
        return ArtworkURLResolver.resolve(artworkURL, size: 600)
    }
}
