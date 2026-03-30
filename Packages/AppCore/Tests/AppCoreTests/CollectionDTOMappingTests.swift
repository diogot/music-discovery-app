import Foundation
import Testing
@testable import AppCore
@testable import iTunesAPI
import Models

@Suite("CollectionDTO → Album Mapping")
struct CollectionDTOMappingTests {

    @Test("Album.from maps all fields correctly")
    func fromMapsAllFields() {
        let dto = CollectionDTO(
            collectionId: 100,
            collectionName: "Test Album",
            artistName: "Test Artist",
            artistId: 200,
            artworkUrl100: URL(string: "https://example.com/100x100.jpg"),
            trackCount: 12,
            releaseDate: "2023-06-15T07:00:00Z",
            primaryGenreName: "Rock",
            copyright: "© 2023 Test"
        )

        let album = Album.from(dto)

        #expect(album.collectionId == 100)
        #expect(album.collectionName == "Test Album")
        #expect(album.artistName == "Test Artist")
        #expect(album.artistId == 200)
        #expect(album.trackCount == 12)
        #expect(album.artworkURL == URL(string: "https://example.com/100x100.jpg"))
        #expect(album.genre == "Rock")
        #expect(album.copyright == "© 2023 Test")
    }

    @Test("Album.from parses ISO8601 releaseDate")
    func fromParsesReleaseDate() {
        let dto = makeCollectionDTO(releaseDate: "2023-06-15T07:00:00Z")
        let album = Album.from(dto)

        let expected = ISO8601DateFormatter().date(from: "2023-06-15T07:00:00Z")
        #expect(album.releaseDate == expected)
    }

    @Test("Album.from handles nil optional fields")
    func fromHandlesNilOptionals() {
        let dto = makeCollectionDTO(
            artworkUrl100: nil,
            releaseDate: nil,
            primaryGenreName: nil,
            copyright: nil
        )
        let album = Album.from(dto)

        #expect(album.artworkURL == nil)
        #expect(album.releaseDate == nil)
        #expect(album.genre == nil)
        #expect(album.copyright == nil)
    }

    @Test("Album.update updates all fields")
    func updateMapsAllFields() {
        let album = Album(
            collectionId: 1,
            collectionName: "Old",
            artistName: "Old Artist",
            artistId: 1,
            trackCount: 5
        )

        let dto = makeCollectionDTO(
            collectionName: "New",
            artistName: "New Artist",
            artistId: 2,
            trackCount: 15,
            primaryGenreName: "Jazz"
        )

        album.update(from: dto)

        #expect(album.collectionName == "New")
        #expect(album.artistName == "New Artist")
        #expect(album.artistId == 2)
        #expect(album.trackCount == 15)
        #expect(album.genre == "Jazz")
    }
}

// MARK: - Helpers

private func makeCollectionDTO(
    collectionId: Int = 1,
    collectionName: String = "Album",
    artistName: String = "Artist",
    artistId: Int = 1,
    artworkUrl100: URL? = URL(string: "https://example.com/100x100.jpg"),
    trackCount: Int = 10,
    releaseDate: String? = "2023-01-01T00:00:00Z",
    primaryGenreName: String? = "Pop",
    copyright: String? = "© 2023"
) -> CollectionDTO {
    CollectionDTO(
        collectionId: collectionId,
        collectionName: collectionName,
        artistName: artistName,
        artistId: artistId,
        artworkUrl100: artworkUrl100,
        trackCount: trackCount,
        releaseDate: releaseDate,
        primaryGenreName: primaryGenreName,
        copyright: copyright
    )
}
