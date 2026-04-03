import Foundation
import Models
import Observation

@Observable
@MainActor
final class SongsViewModel {

    // MARK: - Observable State

    var searchText: String = ""
    private(set) var songs: [Song] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var hasMoreResults = true
    private(set) var error: Error?

    var isSearchActive: Bool { !searchText.isEmpty }

    // MARK: - Private

    private let songRepository: any SongRepository
    private var currentOffset = 0
    private let pageSize = 20
    private var searchTask: Task<Void, Never>?

    // MARK: - Init

    init(songRepository: any SongRepository) {
        self.songRepository = songRepository
    }

    // MARK: - Public

    func searchTextChanged() {
        searchTask?.cancel()
        error = nil

        if searchText.isEmpty {
            currentOffset = 0
            hasMoreResults = true
            loadRecentlyPlayed()
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await performSearch(reset: true)
        }
    }

    func loadRecentlyPlayed() {
        Task {
            isLoading = songs.isEmpty
            songs = await songRepository.recentlyPlayedSongs(limit: 30)
            isLoading = false
        }
    }

    func loadMoreIfNeeded(currentSong: Song) {
        guard isSearchActive,
              !isLoadingMore,
              hasMoreResults,
              currentSong.trackId == songs.last?.trackId else {
            return
        }
        Task { await performSearch(reset: false) }
    }

    func refresh() async {
        error = nil
        if isSearchActive {
            await performSearch(reset: true)
        } else {
            songs = await songRepository.recentlyPlayedSongs(limit: 30)
        }
    }

    // MARK: - Private

    private func performSearch(reset: Bool) async {
        if reset {
            currentOffset = 0
            isLoading = true
        } else {
            isLoadingMore = true
        }
        error = nil

        do {
            let results = try await songRepository.searchSongs(
                term: searchText,
                limit: pageSize,
                offset: currentOffset
            )

            if reset {
                songs = results
            } else {
                songs.append(contentsOf: results)
            }
            currentOffset += results.count
            hasMoreResults = results.count >= pageSize
        } catch {
            if !Task.isCancelled {
                self.error = error
            }
        }

        isLoading = false
        isLoadingMore = false
    }
}
