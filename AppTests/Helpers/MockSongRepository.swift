import Foundation
import Models

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

    func searchSongs(term: String, limit: Int, offset: Int) async throws -> [Song] {
        searchSongsCalls.append((term: term, limit: limit, offset: offset))
        return try searchSongsResult.get()
    }

    func recentlyPlayedSongs(limit: Int) async -> [Song] {
        recentlyPlayedCalls.append(limit)
        return recentlyPlayedResult
    }

    func markAsPlayed(_ song: Song) async throws {
        markAsPlayedCalls.append(song)
    }

    func toggleLike(_ song: Song) async throws {
        toggleLikeCalls.append(song)
    }
}
