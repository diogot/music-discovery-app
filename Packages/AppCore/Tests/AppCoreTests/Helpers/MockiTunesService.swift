import iTunesAPI

final class MockiTunesService: iTunesService, @unchecked Sendable {

    var searchSongsResult: Result<[TrackDTO], Error> = .success([])
    var lookupAlbumResult: Result<AlbumLookupResult, Error>?

    private(set) var searchSongsCalls: [(term: String, limit: Int)] = []
    private(set) var lookupAlbumCalls: [Int] = []

    func searchSongs(term: String, limit: Int) async throws -> [TrackDTO] {
        searchSongsCalls.append((term, limit))
        return try searchSongsResult.get()
    }

    func lookupAlbum(collectionId: Int) async throws -> AlbumLookupResult {
        lookupAlbumCalls.append(collectionId)
        guard let result = lookupAlbumResult else {
            fatalError("lookupAlbumResult not configured")
        }
        return try result.get()
    }
}
