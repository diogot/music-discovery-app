import Foundation
import Models

@MainActor
final class MockAlbumRepository: AlbumRepository {

    // MARK: - Configurable Results

    var fetchAlbumResult: Result<AlbumWithTracks, Error>?

    // MARK: - Call Tracking

    private(set) var fetchAlbumCalls: [Int] = []

    // MARK: - AlbumRepository

    nonisolated func fetchAlbum(collectionId: Int) async throws -> AlbumWithTracks {
        try await MainActor.run {
            fetchAlbumCalls.append(collectionId)
            guard let result = fetchAlbumResult else {
                fatalError("fetchAlbumResult not configured")
            }
            return try result.get()
        }
    }

    nonisolated func album(byCollectionId collectionId: Int) async -> Album? {
        nil
    }
}
