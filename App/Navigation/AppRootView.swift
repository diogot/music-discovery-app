import AppCore
import Models
import SwiftData
import SwiftUI

struct AppRootView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(AudioPlayer.self) private var audioPlayer

    @State private var showSplash = true
    @State private var path: [AppDestination] = []
    @State private var nowPlayingManager: NowPlayingManager?
    @State private var songRepository: (any SongRepository)?
    @State private var albumRepository: (any AlbumRepository)?

    var body: some View {
        ZStack {
            if let nowPlayingManager, let songRepository, let albumRepository {
                NavigationStack(path: $path) {
                    SongsScreen(songRepository: songRepository, path: $path)
                        .navigationDestination(for: AppDestination.self) { destination in
                            switch destination {
                            case .player:
                                PlayerScreen(path: $path)
                            case .album(let collectionId):
                                AlbumScreen(
                                    collectionId: collectionId,
                                    albumRepository: albumRepository,
                                    path: $path
                                )
                            }
                        }
                }
                .environment(nowPlayingManager)
            }

            if showSplash {
                SplashScreen()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            setupDependencies()
            try? await Task.sleep(for: .seconds(2))
            withAnimation(.easeInOut(duration: 0.5)) {
                showSplash = false
            }
        }
        .preferredColorScheme(.dark)
    }

    private func setupDependencies() {
        let songRepo = RepositoryFactory.makeSongRepository(modelContext: modelContext)
        let albumRepo = RepositoryFactory.makeAlbumRepository(modelContext: modelContext)
        songRepository = songRepo
        albumRepository = albumRepo
        nowPlayingManager = NowPlayingManager(
            audioPlayer: audioPlayer,
            songRepository: songRepo
        )
    }
}
