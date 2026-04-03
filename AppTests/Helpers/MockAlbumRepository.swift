import Foundation
import Models

final class MockAlbumRepository: AlbumRepository {

    // MARK: - Configurable Results

    var fetchAlbumResult: Result<AlbumWithTracks, Error>?

    // MARK: - Call Tracking

    private(set) var fetchAlbumCalls: [Int] = []

    // MARK: - AlbumRepository

    func fetchAlbum(collectionId: Int) async throws -> AlbumWithTracks {
        fetchAlbumCalls.append(collectionId)
        guard let result = fetchAlbumResult else {
            fatalError("fetchAlbumResult not configured")
        }
        return try result.get()
    }

    func album(byCollectionId collectionId: Int) async -> Album? {
        nil
    }
}
