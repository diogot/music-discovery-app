import Models
import SwiftData
import SwiftUI

struct AlbumScreen: View {

    @State private var viewModel: AlbumViewModel
    @Environment(NowPlayingManager.self) private var nowPlayingManager
    @Binding var path: [AppDestination]
    let collectionId: Int

    init(collectionId: Int, albumRepository: any AlbumRepository, path: Binding<[AppDestination]>) {
        self.collectionId = collectionId
        _viewModel = State(initialValue: AlbumViewModel(albumRepository: albumRepository))
        _path = path
    }

    var body: some View {
        Group {
            if let albumWithTracks = viewModel.albumWithTracks {
                albumContent(albumWithTracks)
            } else if let error = viewModel.error {
                errorView(error)
            } else {
                loadingView
            }
        }
        .background(Theme.Colors.background)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.loadAlbum(collectionId: collectionId)
        }
    }

    // MARK: - Album Content

    private func albumContent(_ albumWithTracks: AlbumWithTracks) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                albumHeader(albumWithTracks.album)
                    .padding(.top, 16)
                    .padding(.bottom, 32)

                trackList(albumWithTracks.tracks, album: albumWithTracks.album)
            }
            .padding(.horizontal, 24)
        }
        .scrollContentBackground(.hidden)
    }

    // MARK: - Album Header

    private func albumHeader(_ album: Album) -> some View {
        VStack(spacing: 8) {
            ArtworkView(
                url: album.artworkLargeURL,
                size: Theme.Sizing.albumHeaderArtwork
            )
            .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
            .padding(.bottom, 8)

            Text(album.collectionName)
                .font(Theme.Fonts.display(20))
                .foregroundStyle(Theme.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text(album.artistName)
                .font(Theme.Fonts.text(14))
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Track List

    private func trackList(_ tracks: [Song], album: Album) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(tracks, id: \.trackId) { track in
                trackRow(track, album: album)
                    .onTapGesture {
                        path.navigateToPlayer(
                            playing: track,
                            from: tracks,
                            using: nowPlayingManager
                        )
                    }
            }
        }
    }

    private func trackRow(_ track: Song, album: Album) -> some View {
        HStack(spacing: 16) {
            ArtworkView(
                url: album.artworkURL,
                size: Theme.Sizing.albumTrackArtwork
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(track.trackName)
                    .font(Theme.Fonts.text(16))
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .lineLimit(1)

                Text(track.artistName)
                    .font(Theme.Fonts.text(12))
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    // MARK: - State Views

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(Theme.Colors.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(Theme.Colors.textTertiary)
            Text("Could not load album")
                .font(Theme.Fonts.display(18))
                .foregroundStyle(Theme.Colors.textPrimary)
            Text(error.localizedDescription)
                .font(Theme.Fonts.text(14))
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            Button("Retry") {
                viewModel.loadAlbum(collectionId: collectionId)
            }
            .font(Theme.Fonts.text(16))
            .foregroundStyle(Theme.Colors.accent)
            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        AlbumScreen(
            collectionId: 204,
            albumRepository: PreviewHelpers.mockAlbumRepository(),
            path: .constant([])
        )
    }
    .environment(PreviewHelpers.nowPlayingManager())
    .modelContainer(PreviewHelpers.modelContainer)
    .preferredColorScheme(.dark)
}
