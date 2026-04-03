import Foundation
import Models

@MainActor
final class MockSongRepository: SongRepository {

    // MARK: - Configurable Results

    var searchSongsResult: Result<[Song], Error> = .success([])
    var recentlyPlayedResult: [Song] = []

    // MARK: - Call Tracking

    private(set) var searchSongsCalls: [(term: String, limit: Int, offset: Int)] = []
    private(set) var recentlyPlayedCalls: [Int] = []
    private(set) var markAsPlayedCalls: [Song] = []
    private(set) var toggleLikeCalls: [Song] = []

    // MARK: - SongRepository

    nonisolated func searchSongs(term: String, limit: Int, offset: Int) async throws -> [Song] {
        try await MainActor.run {
            searchSongsCalls.append((term: term, limit: limit, offset: offset))
            return try searchSongsResult.get()
        }
    }

    nonisolated func recentlyPlayedSongs(limit: Int) async -> [Song] {
        await MainActor.run {
            recentlyPlayedCalls.append(limit)
            return recentlyPlayedResult
        }
    }

    nonisolated func markAsPlayed(_ song: Song) async throws {
        await MainActor.run {
            markAsPlayedCalls.append(song)
        }
    }

    nonisolated func toggleLike(_ song: Song) async throws {
        await MainActor.run {
            toggleLikeCalls.append(song)
        }
    }
}
