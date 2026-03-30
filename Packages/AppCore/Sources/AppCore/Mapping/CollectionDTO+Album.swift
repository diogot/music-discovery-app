import Foundation
import iTunesAPI
import Models

extension Album {

    /// Creates an Album from an iTunes API CollectionDTO.
    static func from(_ dto: CollectionDTO) -> Album {
        Album(
            collectionId: dto.collectionId,
            collectionName: dto.collectionName,
            artistName: dto.artistName,
            artistId: dto.artistId,
            trackCount: dto.trackCount,
            artworkURL: dto.artworkUrl100,
            releaseDate: dto.releaseDate.flatMap { ISO8601DateParser.parse($0) },
            genre: dto.primaryGenreName,
            copyright: dto.copyright
        )
    }

    /// Updates all fields from a DTO.
    func update(from dto: CollectionDTO) {
        collectionName = dto.collectionName
        artistName = dto.artistName
        artistId = dto.artistId
        trackCount = dto.trackCount
        artworkURL = dto.artworkUrl100
        releaseDate = dto.releaseDate.flatMap { ISO8601DateParser.parse($0) }
        genre = dto.primaryGenreName
        copyright = dto.copyright
    }
}
