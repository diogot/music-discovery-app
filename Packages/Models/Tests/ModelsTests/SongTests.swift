import Foundation
import Testing
@testable import Models

@Suite("Song")
struct SongTests {

    @Test("init stores all properties")
    func initAllProperties() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let playedAt = Date(timeIntervalSince1970: 2_000_000)

        let song = Song(
            trackId: 123,
            trackName: "Get Lucky",
            artistName: "Daft Punk",
            artistId: 456,
            collectionId: 789,
            collectionName: "Random Access Memories",
            trackNumber: 8,
            discNumber: 1,
            discCount: 1,
            trackCount: 13,
            trackTimeMillis: 369_000,
            previewURL: URL(string: "https://example.com/preview.m4a"),
            artworkURL: URL(string: "https://example.com/100x100bb.jpg"),
            releaseDate: date,
            genre: "Electronic",
            lastPlayedAt: playedAt,
            isLiked: true
        )

        #expect(song.trackId == 123)
        #expect(song.trackName == "Get Lucky")
        #expect(song.artistName == "Daft Punk")
        #expect(song.artistId == 456)
        #expect(song.collectionId == 789)
        #expect(song.collectionName == "Random Access Memories")
        #expect(song.trackNumber == 8)
        #expect(song.discNumber == 1)
        #expect(song.discCount == 1)
        #expect(song.trackCount == 13)
        #expect(song.trackTimeMillis == 369_000)
        #expect(song.previewURL == URL(string: "https://example.com/preview.m4a"))
        #expect(song.artworkURL == URL(string: "https://example.com/100x100bb.jpg"))
        #expect(song.releaseDate == date)
        #expect(song.genre == "Electronic")
        #expect(song.lastPlayedAt == playedAt)
        #expect(song.isLiked == true)
    }

    @Test("init applies default values")
    func initDefaults() {
        let song = Song(
            trackId: 1,
            trackName: "Test",
            artistName: "Artist",
            artistId: 2,
            collectionId: 3,
            collectionName: "Album"
        )

        #expect(song.trackNumber == 0)
        #expect(song.discNumber == 1)
        #expect(song.discCount == 1)
        #expect(song.trackCount == 0)
        #expect(song.trackTimeMillis == nil)
        #expect(song.previewURL == nil)
        #expect(song.artworkURL == nil)
        #expect(song.releaseDate == nil)
        #expect(song.genre == nil)
        #expect(song.lastPlayedAt == nil)
        #expect(song.isLiked == false)
    }

    @Test("durationSeconds converts milliseconds")
    func durationSecondsConversion() {
        let song = makeSong(trackTimeMillis: 354_947)

        #expect(song.durationSeconds != nil)
        #expect(song.durationSeconds! == 354.947)
    }

    @Test("durationSeconds returns nil when no millis")
    func durationSecondsNil() {
        let song = makeSong()

        #expect(song.durationSeconds == nil)
    }

    @Test("previewURL stores value")
    func previewURLValid() {
        let song = makeSong(previewURL: URL(string: "https://example.com/preview.m4a"))

        #expect(song.previewURL?.absoluteString == "https://example.com/preview.m4a")
    }

    @Test("previewURL defaults to nil")
    func previewURLNil() {
        let song = makeSong()

        #expect(song.previewURL == nil)
    }

    @Test("artworkLargeURL derives 600x600")
    func artworkLargeDerivesSize() {
        let song = makeSong(artworkURL: URL(string: "https://example.com/100x100bb.jpg"))

        #expect(song.artworkLargeURL?.absoluteString == "https://example.com/600x600bb.jpg")
    }

    @Test("artworkLargeURL returns nil when no URL")
    func artworkLargeNil() {
        let song = makeSong()

        #expect(song.artworkLargeURL == nil)
    }
}

// MARK: - Helpers

private func makeSong(
    trackTimeMillis: Int? = nil,
    previewURL: URL? = nil,
    artworkURL: URL? = nil
) -> Song {
    Song(
        trackId: 1,
        trackName: "Test",
        artistName: "Artist",
        artistId: 2,
        collectionId: 3,
        collectionName: "Album",
        trackTimeMillis: trackTimeMillis,
        previewURL: previewURL,
        artworkURL: artworkURL
    )
}
