import Foundation
import Testing
@testable import Models

@Suite("Album")
struct AlbumTests {

    @Test("init stores all properties")
    func initAllProperties() {
        let date = Date(timeIntervalSince1970: 1_000_000)

        let album = Album(
            collectionId: 789,
            collectionName: "Random Access Memories",
            artistName: "Daft Punk",
            artistId: 456,
            trackCount: 13,
            artworkURL: URL(string: "https://example.com/100x100bb.jpg"),
            releaseDate: date,
            genre: "Electronic",
            copyright: "℗ 2013 Daft Life Limited"
        )

        #expect(album.collectionId == 789)
        #expect(album.collectionName == "Random Access Memories")
        #expect(album.artistName == "Daft Punk")
        #expect(album.artistId == 456)
        #expect(album.trackCount == 13)
        #expect(album.artworkURL == URL(string: "https://example.com/100x100bb.jpg"))
        #expect(album.releaseDate == date)
        #expect(album.genre == "Electronic")
        #expect(album.copyright == "℗ 2013 Daft Life Limited")
    }

    @Test("init applies default values")
    func initDefaults() {
        let album = Album(
            collectionId: 1,
            collectionName: "Test",
            artistName: "Artist",
            artistId: 2
        )

        #expect(album.trackCount == 0)
        #expect(album.artworkURL == nil)
        #expect(album.releaseDate == nil)
        #expect(album.genre == nil)
        #expect(album.copyright == nil)
    }

    @Test("artworkLargeURL derives 600x600")
    func artworkLargeDerivesSize() {
        let album = Album(
            collectionId: 1,
            collectionName: "Test",
            artistName: "Artist",
            artistId: 2,
            artworkURL: URL(string: "https://example.com/100x100bb.jpg")
        )

        #expect(album.artworkLargeURL?.absoluteString == "https://example.com/600x600bb.jpg")
    }

    @Test("artworkLargeURL returns nil when no URL")
    func artworkLargeNil() {
        let album = Album(
            collectionId: 1,
            collectionName: "Test",
            artistName: "Artist",
            artistId: 2
        )

        #expect(album.artworkLargeURL == nil)
    }
}
