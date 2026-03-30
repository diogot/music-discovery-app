import Foundation
import iTunesAPI
import Models

extension Song {

    /// Creates a Song from an iTunes API TrackDTO.
    /// Does NOT set `lastPlayedAt` or `isLiked` — those are local-only fields.
    static func from(_ dto: TrackDTO) -> Song {
        Song(
            trackId: dto.trackId,
            trackName: dto.trackName,
            artistName: dto.artistName,
            artistId: dto.artistId,
            collectionId: dto.collectionId,
            collectionName: dto.collectionName,
            trackNumber: dto.trackNumber,
            discNumber: dto.discNumber,
            discCount: dto.discCount,
            trackCount: dto.trackCount,
            trackTimeMillis: dto.trackTimeMillis,
            previewURL: dto.previewUrl,
            artworkURL: dto.artworkUrl100,
            releaseDate: dto.releaseDate.flatMap { ISO8601DateParser.parse($0) },
            genre: dto.primaryGenreName
        )
    }

    /// Updates API-sourced fields from a DTO, preserving local-only fields
    /// (`isLiked`, `lastPlayedAt`).
    func update(from dto: TrackDTO) {
        trackName = dto.trackName
        artistName = dto.artistName
        artistId = dto.artistId
        collectionId = dto.collectionId
        collectionName = dto.collectionName
        trackNumber = dto.trackNumber
        discNumber = dto.discNumber
        discCount = dto.discCount
        trackCount = dto.trackCount
        trackTimeMillis = dto.trackTimeMillis
        previewURL = dto.previewUrl
        artworkURL = dto.artworkUrl100
        releaseDate = dto.releaseDate.flatMap { ISO8601DateParser.parse($0) }
        genre = dto.primaryGenreName
    }
}

// MARK: - ISO8601DateParser

enum ISO8601DateParser {

    nonisolated(unsafe) private static let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func parse(_ string: String) -> Date? {
        formatter.date(from: string)
    }
}
