public protocol AlbumRepository: Sendable {

    /// Fetch album details and its tracks (from network or cache).
    func fetchAlbum(collectionId: Int) async throws -> AlbumWithTracks

    /// Fetch album from the local cache only.
    func album(byCollectionId collectionId: Int) async -> Album?
}
