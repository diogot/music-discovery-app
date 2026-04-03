@MainActor
public protocol SongRepository {

    /// Search songs by term with pagination.
    func searchSongs(term: String, limit: Int, offset: Int) async throws -> [Song]

    /// Search songs in the local database by term with pagination.
    func searchLocalSongs(term: String, limit: Int, offset: Int) async -> [Song]

    /// Recently played songs, ordered by lastPlayedAt descending.
    func recentlyPlayedSongs(limit: Int) async -> [Song]

    /// Mark a song as played (sets lastPlayedAt to now).
    func markAsPlayed(_ song: Song) async throws

    /// Toggle the liked state of a song.
    func toggleLike(_ song: Song) async throws
}
