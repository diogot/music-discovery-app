import Models
import SwiftData
import SwiftUI

struct SongsScreen: View {

    @State private var viewModel: SongsViewModel
    @Environment(NowPlayingManager.self) private var nowPlayingManager
    @Binding var path: [AppDestination]
    @State private var selectedSongForSheet: Song?

    init(songRepository: any SongRepository, path: Binding<[AppDestination]>) {
        _viewModel = State(initialValue: SongsViewModel(songRepository: songRepository))
        _path = path
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.songs.isEmpty {
                loadingView
            } else if let error = viewModel.error, viewModel.songs.isEmpty {
                errorView(error)
            } else if viewModel.songs.isEmpty {
                emptyView
            } else {
                songList
            }
        }
        .background(Theme.Colors.background)
        .navigationTitle(.songsNavigationTitle)
        .searchable(
            text: Binding(
                get: { viewModel.searchText },
                set: { newValue in
                    viewModel.searchText = newValue
                    viewModel.searchTextChanged()
                }
            ),
            prompt: .songsSearchPrompt
        )
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear {
            viewModel.loadRecentlyPlayed()
        }
    }

    // MARK: - Song List

    private var songList: some View {
        List {
            ForEach(viewModel.songs, id: \.trackId) { song in
                SongRowView(song: song) {
                    selectedSongForSheet = song
                }
                .listRowBackground(Theme.Colors.background)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                .contentShape(Rectangle())
                .onTapGesture {
                    path.navigateToPlayer(
                        playing: song,
                        from: viewModel.songs,
                        using: nowPlayingManager
                    )
                }
                .onAppear {
                    viewModel.loadMoreIfNeeded(currentSong: song)
                }
            }

            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(Theme.Colors.textSecondary)
                    Spacer()
                }
                .listRowBackground(Theme.Colors.background)
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .listRowSpacing(0)
        .scrollContentBackground(.hidden)
        .sheet(item: $selectedSongForSheet) { song in
            MoreOptionsSheet(song: song) {
                path.append(AppDestination.album(collectionId: song.collectionId))
            }
        }
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
            Text(.songsErrorTitle)
                .font(Theme.Fonts.display(18))
                .foregroundStyle(Theme.Colors.textPrimary)
            Text(error.localizedDescription)
                .font(Theme.Fonts.text(14))
                .foregroundStyle(Theme.Colors.textSecondary)
                .multilineTextAlignment(.center)
            Button(.commonRetryButton) {
                viewModel.searchTextChanged()
            }
            .font(Theme.Fonts.text(16))
            .foregroundStyle(Theme.Colors.accent)
            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 40))
                .foregroundStyle(Theme.Colors.textTertiary)
            Group {
                if viewModel.isSearchActive {
                    Text(.songsNoResultsMessage(viewModel.searchText))
                } else {
                    Text(.songsEmptyMessage)
                }
            }
            .font(Theme.Fonts.text(16))
            .foregroundStyle(Theme.Colors.textSecondary)
            .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        SongsScreen(
            songRepository: PreviewHelpers.mockSongRepository(),
            path: .constant([])
        )
    }
    .environment(PreviewHelpers.nowPlayingManager())
    .modelContainer(PreviewHelpers.modelContainer)
    .preferredColorScheme(.dark)
}
