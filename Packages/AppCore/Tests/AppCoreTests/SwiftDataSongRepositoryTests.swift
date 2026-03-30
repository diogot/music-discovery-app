import Foundation
import SwiftData
import Testing
@testable import AppCore
@testable import iTunesAPI
import Models

@Suite("SwiftDataSongRepository", .serialized)
@MainActor
struct SwiftDataSongRepositoryTests {

    private let container: ModelContainer
    private let mock: MockiTunesService
    private let repository: SwiftDataSongRepository

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Song.self, Album.self, configurations: config)
        mock = MockiTunesService()
        repository = SwiftDataSongRepository(
            iTunesService: mock,
            modelContext: container.mainContext
        )
    }

    // MARK: - searchSongs

    @Test("searchSongs returns mapped songs")
    func searchSongsReturnsMapped() async throws {
        mock.searchSongsResult = .success([
            makeTrackDTO(trackId: 1, trackName: "Song 1"),
            makeTrackDTO(trackId: 2, trackName: "Song 2"),
        ])

        let songs = try await repository.searchSongs(term: "test", limit: 10, offset: 0)

        #expect(songs.count == 2)
        #expect(songs[0].trackId == 1)
        #expect(songs[0].trackName == "Song 1")
        #expect(songs[1].trackId == 2)
        #expect(songs[1].trackName == "Song 2")
    }

    @Test("searchSongs passes correct parameters to iTunesService")
    func searchSongsPassesParams() async throws {
        mock.searchSongsResult = .success([])

        _ = try await repository.searchSongs(term: "hello", limit: 25, offset: 50)

        let call = try #require(mock.searchSongsCalls.first)
        #expect(call.term == "hello")
        #expect(call.limit == 25)
        #expect(call.offset == 50)
    }

    @Test("searchSongs upserts existing songs preserving isLiked")
    func searchSongsPreservesIsLiked() async throws {
        let existing = Song(
            trackId: 1,
            trackName: "Old Name",
            artistName: "Artist",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album",
            isLiked: true
        )
        container.mainContext.insert(existing)
        try container.mainContext.save()

        mock.searchSongsResult = .success([
            makeTrackDTO(trackId: 1, trackName: "New Name"),
        ])

        let songs = try await repository.searchSongs(term: "test", limit: 10, offset: 0)

        #expect(songs.count == 1)
        #expect(songs[0].trackName == "New Name")
        #expect(songs[0].isLiked == true)
    }

    @Test("searchSongs upserts existing songs preserving lastPlayedAt")
    func searchSongsPreservesLastPlayedAt() async throws {
        let playedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let existing = Song(
            trackId: 1,
            trackName: "Old",
            artistName: "Artist",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album",
            lastPlayedAt: playedDate
        )
        container.mainContext.insert(existing)
        try container.mainContext.save()

        mock.searchSongsResult = .success([
            makeTrackDTO(trackId: 1, trackName: "Updated"),
        ])

        let songs = try await repository.searchSongs(term: "test", limit: 10, offset: 0)

        #expect(songs[0].trackName == "Updated")
        #expect(songs[0].lastPlayedAt == playedDate)
    }

    @Test("searchSongs inserts new songs when none exist")
    func searchSongsInsertsNew() async throws {
        mock.searchSongsResult = .success([
            makeTrackDTO(trackId: 99, trackName: "Brand New"),
        ])

        let songs = try await repository.searchSongs(term: "test", limit: 10, offset: 0)

        #expect(songs.count == 1)
        #expect(songs[0].trackId == 99)

        let descriptor = FetchDescriptor<Song>()
        let allSongs = try container.mainContext.fetch(descriptor)
        #expect(allSongs.count == 1)
    }

    @Test("searchSongs propagates network errors")
    func searchSongsPropagatesErrors() async {
        mock.searchSongsResult = .failure(URLError(.notConnectedToInternet))

        await #expect(throws: URLError.self) {
            _ = try await repository.searchSongs(term: "test", limit: 10, offset: 0)
        }
    }

    // MARK: - recentlyPlayedSongs

    @Test("recentlyPlayedSongs returns sorted by lastPlayedAt descending")
    func recentlyPlayedSorted() async throws {
        let now = Date()
        insertSong(trackId: 1, lastPlayedAt: now.addingTimeInterval(-100))
        insertSong(trackId: 2, lastPlayedAt: now.addingTimeInterval(-50))
        insertSong(trackId: 3, lastPlayedAt: now)
        try container.mainContext.save()

        let songs = await repository.recentlyPlayedSongs(limit: 10)

        #expect(songs.count == 3)
        #expect(songs[0].trackId == 3)
        #expect(songs[1].trackId == 2)
        #expect(songs[2].trackId == 1)
    }

    @Test("recentlyPlayedSongs excludes songs with nil lastPlayedAt")
    func recentlyPlayedExcludesNil() async throws {
        insertSong(trackId: 1, lastPlayedAt: Date())
        insertSong(trackId: 2, lastPlayedAt: nil)
        try container.mainContext.save()

        let songs = await repository.recentlyPlayedSongs(limit: 10)

        #expect(songs.count == 1)
        #expect(songs[0].trackId == 1)
    }

    @Test("recentlyPlayedSongs respects limit")
    func recentlyPlayedRespectsLimit() async throws {
        let now = Date()
        for i in 1...5 {
            insertSong(trackId: i, lastPlayedAt: now.addingTimeInterval(Double(-i)))
        }
        try container.mainContext.save()

        let songs = await repository.recentlyPlayedSongs(limit: 3)

        #expect(songs.count == 3)
    }

    @Test("recentlyPlayedSongs returns empty when none played")
    func recentlyPlayedEmpty() async throws {
        insertSong(trackId: 1, lastPlayedAt: nil)
        try container.mainContext.save()

        let songs = await repository.recentlyPlayedSongs(limit: 10)

        #expect(songs.isEmpty)
    }

    // MARK: - markAsPlayed

    @Test("markAsPlayed sets lastPlayedAt")
    func markAsPlayedSetsDate() async throws {
        let song = Song(
            trackId: 1,
            trackName: "Song",
            artistName: "Artist",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album"
        )
        container.mainContext.insert(song)
        try container.mainContext.save()

        #expect(song.lastPlayedAt == nil)

        try await repository.markAsPlayed(song)

        #expect(song.lastPlayedAt != nil)
    }

    // MARK: - toggleLike

    @Test("toggleLike flips false to true")
    func toggleLikeFalseToTrue() async throws {
        let song = Song(
            trackId: 1,
            trackName: "Song",
            artistName: "Artist",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album",
            isLiked: false
        )
        container.mainContext.insert(song)
        try container.mainContext.save()

        try await repository.toggleLike(song)

        #expect(song.isLiked == true)
    }

    @Test("toggleLike flips true to false")
    func toggleLikeTrueToFalse() async throws {
        let song = Song(
            trackId: 1,
            trackName: "Song",
            artistName: "Artist",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album",
            isLiked: true
        )
        container.mainContext.insert(song)
        try container.mainContext.save()

        try await repository.toggleLike(song)

        #expect(song.isLiked == false)
    }

    // MARK: - Helpers

    private func insertSong(trackId: Int, lastPlayedAt: Date?) {
        let song = Song(
            trackId: trackId,
            trackName: "Song \(trackId)",
            artistName: "Artist",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album",
            lastPlayedAt: lastPlayedAt
        )
        container.mainContext.insert(song)
    }
}

// MARK: - DTO Factory

private func makeTrackDTO(
    trackId: Int = 1,
    trackName: String = "Test",
    artistName: String = "Artist",
    artistId: Int = 1,
    collectionId: Int = 1,
    collectionName: String = "Album"
) -> TrackDTO {
    TrackDTO(
        trackId: trackId,
        trackName: trackName,
        artistName: artistName,
        artistId: artistId,
        collectionId: collectionId,
        collectionName: collectionName,
        trackNumber: 1,
        trackCount: 10,
        discNumber: 1,
        discCount: 1,
        trackTimeMillis: 30000,
        previewUrl: URL(string: "https://example.com/preview.m4a"),
        artworkUrl100: URL(string: "https://example.com/100x100.jpg"),
        releaseDate: "2023-01-01T00:00:00Z",
        primaryGenreName: "Pop"
    )
}
