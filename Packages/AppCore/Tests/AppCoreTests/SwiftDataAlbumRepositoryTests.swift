import Foundation
import SwiftData
import Testing
@testable import AppCore
@testable import iTunesAPI
import Models

@Suite("SwiftDataAlbumRepository", .serialized)
@MainActor
struct SwiftDataAlbumRepositoryTests {

    private let container: ModelContainer
    private let mock: MockiTunesService
    private let repository: SwiftDataAlbumRepository

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Song.self, Album.self, configurations: config)
        mock = MockiTunesService()
        repository = SwiftDataAlbumRepository(
            iTunesService: mock,
            modelContext: container.mainContext
        )
    }

    // MARK: - fetchAlbum

    @Test("fetchAlbum returns album with sorted tracks")
    func fetchAlbumReturnsSorted() async throws {
        mock.lookupAlbumResult = .success(AlbumLookupResult(
            collection: makeCollectionDTO(collectionId: 100),
            tracks: [
                makeTrackDTO(trackId: 3, trackNumber: 3, discNumber: 1),
                makeTrackDTO(trackId: 1, trackNumber: 1, discNumber: 1),
                makeTrackDTO(trackId: 2, trackNumber: 2, discNumber: 1),
            ]
        ))

        let result = try await repository.fetchAlbum(collectionId: 100)

        #expect(result.album.collectionId == 100)
        #expect(result.tracks.count == 3)
        #expect(result.tracks[0].trackNumber == 1)
        #expect(result.tracks[1].trackNumber == 2)
        #expect(result.tracks[2].trackNumber == 3)
    }

    @Test("fetchAlbum upserts existing album")
    func fetchAlbumUpsertsAlbum() async throws {
        let existing = Album(
            collectionId: 100,
            collectionName: "Old Name",
            artistName: "Artist",
            artistId: 1
        )
        container.mainContext.insert(existing)
        try container.mainContext.save()

        mock.lookupAlbumResult = .success(AlbumLookupResult(
            collection: makeCollectionDTO(collectionId: 100, collectionName: "New Name"),
            tracks: []
        ))

        let result = try await repository.fetchAlbum(collectionId: 100)

        #expect(result.album.collectionName == "New Name")

        let descriptor = FetchDescriptor<Album>()
        let allAlbums = try container.mainContext.fetch(descriptor)
        #expect(allAlbums.count == 1)
    }

    @Test("fetchAlbum upserts existing songs preserving local fields")
    func fetchAlbumPreservesLocalFields() async throws {
        let existing = Song(
            trackId: 1,
            trackName: "Old",
            artistName: "Artist",
            artistId: 1,
            collectionId: 100,
            collectionName: "Album",
            lastPlayedAt: Date(),
            isLiked: true
        )
        container.mainContext.insert(existing)

        let existingAlbum = Album(
            collectionId: 100,
            collectionName: "Album",
            artistName: "Artist",
            artistId: 1
        )
        container.mainContext.insert(existingAlbum)
        try container.mainContext.save()

        mock.lookupAlbumResult = .success(AlbumLookupResult(
            collection: makeCollectionDTO(collectionId: 100),
            tracks: [makeTrackDTO(trackId: 1, trackName: "Updated")]
        ))

        let result = try await repository.fetchAlbum(collectionId: 100)

        #expect(result.tracks[0].trackName == "Updated")
        #expect(result.tracks[0].isLiked == true)
        #expect(result.tracks[0].lastPlayedAt != nil)
    }

    @Test("fetchAlbum sorts tracks by discNumber then trackNumber")
    func fetchAlbumSortsMultiDisc() async throws {
        mock.lookupAlbumResult = .success(AlbumLookupResult(
            collection: makeCollectionDTO(collectionId: 100),
            tracks: [
                makeTrackDTO(trackId: 4, trackNumber: 1, discNumber: 2),
                makeTrackDTO(trackId: 1, trackNumber: 1, discNumber: 1),
                makeTrackDTO(trackId: 3, trackNumber: 3, discNumber: 1),
                makeTrackDTO(trackId: 2, trackNumber: 2, discNumber: 1),
            ]
        ))

        let result = try await repository.fetchAlbum(collectionId: 100)

        #expect(result.tracks.map(\.trackId) == [1, 2, 3, 4])
    }

    @Test("fetchAlbum propagates network errors")
    func fetchAlbumPropagatesErrors() async {
        mock.lookupAlbumResult = .failure(URLError(.notConnectedToInternet))

        await #expect(throws: URLError.self) {
            _ = try await repository.fetchAlbum(collectionId: 100)
        }
    }

    // MARK: - album(byCollectionId:)

    @Test("album(byCollectionId:) returns cached album")
    func albumByIdReturnsCached() async throws {
        let album = Album(
            collectionId: 42,
            collectionName: "Cached Album",
            artistName: "Artist",
            artistId: 1
        )
        container.mainContext.insert(album)
        try container.mainContext.save()

        let result = await repository.album(byCollectionId: 42)

        #expect(result?.collectionId == 42)
        #expect(result?.collectionName == "Cached Album")
    }

    @Test("album(byCollectionId:) returns nil when not found")
    func albumByIdReturnsNil() async {
        let result = await repository.album(byCollectionId: 999)

        #expect(result == nil)
    }
}

// MARK: - DTO Factories

private func makeTrackDTO(
    trackId: Int = 1,
    trackName: String = "Track",
    trackNumber: Int = 1,
    discNumber: Int = 1
) -> TrackDTO {
    TrackDTO(
        trackId: trackId,
        trackName: trackName,
        artistName: "Artist",
        artistId: 1,
        collectionId: 100,
        collectionName: "Album",
        trackNumber: trackNumber,
        trackCount: 10,
        discNumber: discNumber,
        discCount: 1,
        trackTimeMillis: 30000,
        previewUrl: URL(string: "https://example.com/preview.m4a"),
        artworkUrl100: URL(string: "https://example.com/100x100.jpg"),
        releaseDate: "2023-01-01T00:00:00Z",
        primaryGenreName: "Pop"
    )
}

private func makeCollectionDTO(
    collectionId: Int = 100,
    collectionName: String = "Album"
) -> CollectionDTO {
    CollectionDTO(
        collectionId: collectionId,
        collectionName: collectionName,
        artistName: "Artist",
        artistId: 1,
        artworkUrl100: URL(string: "https://example.com/100x100.jpg"),
        trackCount: 10,
        releaseDate: "2023-01-01T00:00:00Z",
        primaryGenreName: "Pop",
        copyright: "© 2023"
    )
}
