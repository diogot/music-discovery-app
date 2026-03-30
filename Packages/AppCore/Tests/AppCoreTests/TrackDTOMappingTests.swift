import Foundation
import Testing
@testable import AppCore
@testable import iTunesAPI
import Models

@Suite("TrackDTO → Song Mapping")
struct TrackDTOMappingTests {

    @Test("Song.from maps all fields correctly")
    func fromMapsAllFields() {
        let dto = TrackDTO(
            trackId: 123,
            trackName: "Test Song",
            artistName: "Test Artist",
            artistId: 456,
            collectionId: 789,
            collectionName: "Test Album",
            trackNumber: 3,
            trackCount: 12,
            discNumber: 1,
            discCount: 2,
            trackTimeMillis: 210000,
            previewUrl: URL(string: "https://example.com/preview.m4a"),
            artworkUrl100: URL(string: "https://example.com/100x100.jpg"),
            releaseDate: "2023-06-15T07:00:00Z",
            primaryGenreName: "Pop"
        )

        let song = Song.from(dto)

        #expect(song.trackId == 123)
        #expect(song.trackName == "Test Song")
        #expect(song.artistName == "Test Artist")
        #expect(song.artistId == 456)
        #expect(song.collectionId == 789)
        #expect(song.collectionName == "Test Album")
        #expect(song.trackNumber == 3)
        #expect(song.trackCount == 12)
        #expect(song.discNumber == 1)
        #expect(song.discCount == 2)
        #expect(song.trackTimeMillis == 210000)
        #expect(song.previewURL == URL(string: "https://example.com/preview.m4a"))
        #expect(song.artworkURL == URL(string: "https://example.com/100x100.jpg"))
        #expect(song.genre == "Pop")
    }

    @Test("Song.from parses ISO8601 releaseDate")
    func fromParsesReleaseDate() {
        let dto = makeDTO(releaseDate: "2023-06-15T07:00:00Z")
        let song = Song.from(dto)

        let expected = ISO8601DateFormatter().date(from: "2023-06-15T07:00:00Z")
        #expect(song.releaseDate == expected)
    }

    @Test("Song.from handles nil optional fields")
    func fromHandlesNilOptionals() {
        let dto = makeDTO(
            trackTimeMillis: nil,
            previewUrl: nil,
            artworkUrl100: nil,
            releaseDate: nil,
            primaryGenreName: nil
        )
        let song = Song.from(dto)

        #expect(song.trackTimeMillis == nil)
        #expect(song.previewURL == nil)
        #expect(song.artworkURL == nil)
        #expect(song.releaseDate == nil)
        #expect(song.genre == nil)
    }

    @Test("Song.from defaults isLiked to false and lastPlayedAt to nil")
    func fromDefaultsLocalFields() {
        let dto = makeDTO()
        let song = Song.from(dto)

        #expect(song.isLiked == false)
        #expect(song.lastPlayedAt == nil)
    }

    @Test("Song.update updates API-sourced fields")
    func updateMapsFields() {
        let song = Song(
            trackId: 1,
            trackName: "Old Name",
            artistName: "Old Artist",
            artistId: 1,
            collectionId: 1,
            collectionName: "Old Album"
        )

        let dto = makeDTO(
            trackId: 1,
            trackName: "New Name",
            artistName: "New Artist",
            artistId: 2,
            collectionId: 2,
            collectionName: "New Album"
        )

        song.update(from: dto)

        #expect(song.trackName == "New Name")
        #expect(song.artistName == "New Artist")
        #expect(song.artistId == 2)
        #expect(song.collectionId == 2)
        #expect(song.collectionName == "New Album")
    }

    @Test("Song.update preserves isLiked")
    func updatePreservesIsLiked() {
        let song = Song(
            trackId: 1,
            trackName: "Song",
            artistName: "Artist",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album",
            isLiked: true
        )

        song.update(from: makeDTO(trackId: 1))

        #expect(song.isLiked == true)
    }

    @Test("Song.update preserves lastPlayedAt")
    func updatePreservesLastPlayedAt() {
        let playedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let song = Song(
            trackId: 1,
            trackName: "Song",
            artistName: "Artist",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album",
            lastPlayedAt: playedDate
        )

        song.update(from: makeDTO(trackId: 1))

        #expect(song.lastPlayedAt == playedDate)
    }

    @Test("ISO8601DateParser parses valid date")
    func parserParsesValid() {
        let date = ISO8601DateParser.parse("2023-06-15T07:00:00Z")
        #expect(date != nil)

        let expected = ISO8601DateFormatter().date(from: "2023-06-15T07:00:00Z")
        #expect(date == expected)
    }

    @Test("ISO8601DateParser returns nil for invalid string")
    func parserReturnsNilForInvalid() {
        #expect(ISO8601DateParser.parse("not-a-date") == nil)
        #expect(ISO8601DateParser.parse("") == nil)
    }
}

// MARK: - Helpers

private func makeDTO(
    trackId: Int = 1,
    trackName: String = "Test",
    artistName: String = "Artist",
    artistId: Int = 1,
    collectionId: Int = 1,
    collectionName: String = "Album",
    trackNumber: Int = 1,
    trackCount: Int = 10,
    discNumber: Int = 1,
    discCount: Int = 1,
    trackTimeMillis: Int? = 30000,
    previewUrl: URL? = URL(string: "https://example.com/preview.m4a"),
    artworkUrl100: URL? = URL(string: "https://example.com/100x100.jpg"),
    releaseDate: String? = "2023-01-01T00:00:00Z",
    primaryGenreName: String? = "Pop"
) -> TrackDTO {
    TrackDTO(
        trackId: trackId,
        trackName: trackName,
        artistName: artistName,
        artistId: artistId,
        collectionId: collectionId,
        collectionName: collectionName,
        trackNumber: trackNumber,
        trackCount: trackCount,
        discNumber: discNumber,
        discCount: discCount,
        trackTimeMillis: trackTimeMillis,
        previewUrl: previewUrl,
        artworkUrl100: artworkUrl100,
        releaseDate: releaseDate,
        primaryGenreName: primaryGenreName
    )
}
