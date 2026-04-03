import Foundation
import Models
import Observation

@Observable
@MainActor
final class AlbumViewModel {

    // MARK: - Observable State

    private(set) var albumWithTracks: AlbumWithTracks?
    private(set) var isLoading = false
    private(set) var error: Error?

    // MARK: - Private

    private let albumRepository: any AlbumRepository

    // MARK: - Init

    init(albumRepository: any AlbumRepository) {
        self.albumRepository = albumRepository
    }

    // MARK: - Public

    func loadAlbum(collectionId: Int) {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        Task {
            do {
                albumWithTracks = try await albumRepository.fetchAlbum(
                    collectionId: collectionId
                )
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}
