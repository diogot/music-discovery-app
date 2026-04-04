import Foundation
import Models
import NetworkService
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
    private let debounceInterval: Duration
    private let pageSize = 20
    private var searchTask: Task<Void, Never>?

    // MARK: - Init

    init(songRepository: any SongRepository, debounceInterval: Duration = .milliseconds(300)) {
        self.songRepository = songRepository
        self.debounceInterval = debounceInterval
    }

    // MARK: - Public

    func searchTextChanged() {
        searchTask?.cancel()
        error = nil

        if searchText.isEmpty {
            hasMoreResults = true
            loadRecentlyPlayed()
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: debounceInterval)
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
        isLoadingMore = true
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
        let limit = reset ? pageSize : songs.count + pageSize
        if reset {
            isLoading = true
        }
        error = nil

        do {
            let results = try await songRepository.searchSongs(
                term: searchText,
                limit: limit
            )
            songs = results
            hasMoreResults = results.count >= limit
        } catch let networkError as NetworkError where networkError == .noInternet {
            if reset {
                let localResults = await songRepository.searchLocalSongs(
                    term: searchText,
                    limit: pageSize,
                    offset: 0
                )
                songs = localResults
                hasMoreResults = false
            }
            if !Task.isCancelled {
                self.error = networkError
            }
        } catch {
            if !Task.isCancelled {
                self.error = error
            }
        }

        isLoading = false
        isLoadingMore = false
    }
}
