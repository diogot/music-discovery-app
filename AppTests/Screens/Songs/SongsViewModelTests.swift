import Foundation
import Models
import NetworkService
import Testing
@testable import MusicDiscovery

@Suite("SongsViewModel")
@MainActor
struct SongsViewModelTests {

    private let mock: MockSongRepository
    private let viewModel: SongsViewModel

    init() {
        mock = MockSongRepository()
        viewModel = SongsViewModel(songRepository: mock, debounceInterval: .zero)
    }

    // MARK: - Initial State

    @Test("initial state")
    func initialState() {
        #expect(viewModel.songs.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.isLoadingMore == false)
        #expect(viewModel.hasMoreResults == true)
        #expect(viewModel.error == nil)
        #expect(viewModel.isSearchActive == false)
    }

    // MARK: - Refresh

    @Test("refresh without search loads recently played")
    func refreshWithoutSearchLoadsRecentlyPlayed() async {
        let recentSongs = [makeSong(trackId: 1), makeSong(trackId: 2)]
        mock.recentlyPlayedResult = recentSongs

        await viewModel.refresh()

        #expect(viewModel.songs.count == 2)
        #expect(viewModel.songs[0].trackId == 1)
        #expect(viewModel.songs[1].trackId == 2)
    }

    @Test("refresh with search performs search")
    func refreshWithSearchPerformsSearch() async {
        let results = [makeSong(trackId: 10, trackName: "Found")]
        mock.searchSongsResult = .success(results)
        viewModel.searchText = "test"

        await viewModel.refresh()

        #expect(viewModel.songs.count == 1)
        #expect(viewModel.songs[0].trackName == "Found")
        #expect(mock.searchSongsCalls.count == 1)
        #expect(mock.searchSongsCalls[0].term == "test")
    }

    @Test("search sets error on failure")
    func searchSetsErrorOnFailure() async {
        mock.searchSongsResult = .failure(URLError(.notConnectedToInternet))
        viewModel.searchText = "query"

        await viewModel.refresh()

        #expect(viewModel.error != nil)
        #expect(viewModel.songs.isEmpty)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - searchTextChanged

    @Test("searchTextChanged triggers search")
    func searchTextChangedTriggersSearch() async {
        mock.searchSongsResult = .success([makeSong(trackId: 5)])
        viewModel.searchText = "hello"

        viewModel.searchTextChanged()
        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.songs.count == 1)
        #expect(viewModel.songs[0].trackId == 5)
    }

    @Test("searchTextChanged with empty text loads recently played")
    func searchTextChangedClearTextLoadsRecent() async {
        mock.recentlyPlayedResult = [makeSong(trackId: 99)]
        viewModel.searchText = ""

        viewModel.searchTextChanged()
        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.songs.count == 1)
        #expect(viewModel.songs[0].trackId == 99)
    }

    @Test("searchTextChanged cancels previous search")
    func searchTextChangedCancelsPreviousSearch() async {
        mock.searchSongsResult = .success([makeSong()])
        viewModel.searchText = "first"
        viewModel.searchTextChanged()

        viewModel.searchText = "second"
        viewModel.searchTextChanged()
        try? await Task.sleep(for: .milliseconds(50))

        let searchTerms = mock.searchSongsCalls.map(\.term)
        #expect(!searchTerms.contains("first"))
        #expect(searchTerms.contains("second"))
    }

    // MARK: - Pagination

    @Test("hasMoreResults false when page incomplete")
    func hasMoreResultsFalseWhenPageIncomplete() async {
        // pageSize is 20, return fewer
        let fewResults = (1...5).map { makeSong(trackId: $0) }
        mock.searchSongsResult = .success(fewResults)
        viewModel.searchText = "query"

        await viewModel.refresh()

        #expect(viewModel.hasMoreResults == false)
    }

    @Test("loadMoreIfNeeded triggers next page at last song")
    func loadMoreIfNeededTriggersNextPage() async {
        // First page: 20 results (full page)
        let firstPage = (1...20).map { makeSong(trackId: $0) }
        mock.searchSongsResult = .success(firstPage)
        viewModel.searchText = "query"
        await viewModel.refresh()

        // Set up second page
        let secondPage = [makeSong(trackId: 21)]
        mock.searchSongsResult = .success(secondPage)

        // Trigger load more with the last song
        viewModel.loadMoreIfNeeded(currentSong: viewModel.songs.last!)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.songs.count == 21)
        #expect(mock.searchSongsCalls.count == 2)
        #expect(mock.searchSongsCalls[1].offset == 20)
    }

    // MARK: - Offline Fallback

    @Test("noInternet on reset falls back to local search")
    func noInternetOnResetFallsBackToLocalSearch() async {
        mock.searchSongsResult = .failure(NetworkError.noInternet)
        let cached = [makeSong(trackId: 50, trackName: "Cached")]
        mock.searchLocalSongsResult = cached
        viewModel.searchText = "query"

        await viewModel.refresh()

        #expect(viewModel.songs.count == 1)
        #expect(viewModel.songs[0].trackId == 50)
        #expect(mock.searchLocalSongsCalls.count == 1)
        #expect(mock.searchLocalSongsCalls[0].term == "query")
        #expect(viewModel.error != nil)
    }

    @Test("noInternet replaces existing songs with local results on reset")
    func noInternetReplacesExistingSongsWithLocalResults() async {
        // Load initial results
        let initial = [makeSong(trackId: 1)]
        mock.searchSongsResult = .success(initial)
        viewModel.searchText = "query"
        await viewModel.refresh()
        #expect(viewModel.songs.count == 1)

        // Now simulate offline — local search replaces old results
        mock.searchSongsResult = .failure(NetworkError.noInternet)
        mock.searchLocalSongsResult = [makeSong(trackId: 99)]

        await viewModel.refresh()

        #expect(mock.searchLocalSongsCalls.count == 1)
        #expect(viewModel.songs.count == 1)
        #expect(viewModel.songs[0].trackId == 99)
        #expect(viewModel.error != nil)
    }

    // MARK: - Pagination (continued)

    @Test("loadMoreIfNeeded ignores non-last song")
    func loadMoreIfNeededIgnoresNonLastSong() async {
        let firstPage = (1...20).map { makeSong(trackId: $0) }
        mock.searchSongsResult = .success(firstPage)
        viewModel.searchText = "query"
        await viewModel.refresh()

        let callsBefore = mock.searchSongsCalls.count
        viewModel.loadMoreIfNeeded(currentSong: viewModel.songs[0])

        #expect(mock.searchSongsCalls.count == callsBefore)
    }
}
