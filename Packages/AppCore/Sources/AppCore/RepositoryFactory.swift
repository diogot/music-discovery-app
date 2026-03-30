import Foundation
import iTunesAPI
import Models
import NetworkService
import SwiftData

@MainActor
public enum RepositoryFactory {

    private static let iTunesBaseURL = URL(string: "https://itunes.apple.com")!

    public static func makeSongRepository(
        modelContext: ModelContext
    ) -> some SongRepository {
        let networkService = URLSessionNetworkService(baseURL: iTunesBaseURL)
        let iTunesService = LiveiTunesService(networkService: networkService)
        return SwiftDataSongRepository(
            iTunesService: iTunesService,
            modelContext: modelContext
        )
    }

    public static func makeAlbumRepository(
        modelContext: ModelContext
    ) -> some AlbumRepository {
        let networkService = URLSessionNetworkService(baseURL: iTunesBaseURL)
        let iTunesService = LiveiTunesService(networkService: networkService)
        return SwiftDataAlbumRepository(
            iTunesService: iTunesService,
            modelContext: modelContext
        )
    }
}
