import Foundation
import SwiftData

@Model
public final class Album {

    @Attribute(.unique)
    public var collectionId: Int

    public var collectionName: String
    public var artistName: String
    public var artistId: Int
    public var trackCount: Int
    public var artworkURLString: String?
    public var releaseDate: Date?
    public var genre: String?
    public var copyright: String?

    public init(
        collectionId: Int,
        collectionName: String,
        artistName: String,
        artistId: Int,
        trackCount: Int = 0,
        artworkURLString: String? = nil,
        releaseDate: Date? = nil,
        genre: String? = nil,
        copyright: String? = nil
    ) {
        self.collectionId = collectionId
        self.collectionName = collectionName
        self.artistName = artistName
        self.artistId = artistId
        self.trackCount = trackCount
        self.artworkURLString = artworkURLString
        self.releaseDate = releaseDate
        self.genre = genre
        self.copyright = copyright
    }

    // MARK: - Computed Properties

    public var artworkThumbnailURL: URL? {
        guard let artworkURLString else { return nil }
        return URL(string: artworkURLString)
    }

    public var artworkLargeURL: URL? {
        guard let artworkURLString else { return nil }
        return ArtworkURLResolver.resolve(artworkURLString, size: 600)
    }
}
