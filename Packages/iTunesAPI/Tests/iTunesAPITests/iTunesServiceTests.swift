import Foundation
import Testing
import NetworkService
import TestUtils
@testable import iTunesAPI

@Suite("iTunesService")
struct iTunesServiceTests {
    private func makeService(mock: MockNetworkService = MockNetworkService()) -> (LiveiTunesService, MockNetworkService) {
        (LiveiTunesService(networkService: mock), mock)
    }

    // MARK: - searchSongs

    @Test("searchSongs returns tracks from fixture response")
    func searchSongsReturnsTracks() async throws {
        let (service, mock) = makeService()
        let fixtureURL = try #require(
            Bundle.module.url(forResource: "search_response", withExtension: "json", subdirectory: "Fixtures")
        )
        mock.setResponse(try Data(contentsOf: fixtureURL))

        let tracks = try await service.searchSongs(term: "Queen", limit: 25, offset: 0)

        #expect(tracks.count == 2)
        #expect(tracks[0].trackName == "Bohemian Rhapsody")
        #expect(tracks[1].trackName == "Love of My Life")
    }

    @Test("searchSongs passes correct Request to network service")
    func searchSongsPassesCorrectRequest() async throws {
        let (service, mock) = makeService()
        let fixtureURL = try #require(
            Bundle.module.url(forResource: "search_response", withExtension: "json", subdirectory: "Fixtures")
        )
        mock.setResponse(try Data(contentsOf: fixtureURL))

        _ = try await service.searchSongs(term: "Queen", limit: 25, offset: 10)

        let request = try #require(mock.executedRequests.first)
        #expect(request.path == "/search")
        #expect(request.queryItems["term"] == "Queen")
        #expect(request.queryItems["limit"] == "25")
        #expect(request.queryItems["offset"] == "10")
    }

    @Test("searchSongs with empty results returns empty array")
    func searchSongsEmptyResults() async throws {
        let (service, mock) = makeService()
        let json = """
        {"resultCount": 0, "results": []}
        """
        mock.setResponse(Data(json.utf8))

        let tracks = try await service.searchSongs(term: "xyznonexistent", limit: 25, offset: 0)

        #expect(tracks.isEmpty)
    }

    @Test("searchSongs propagates network errors")
    func searchSongsPropagatesErrors() async {
        let (service, mock) = makeService()
        mock.setError(.noInternet)

        await #expect(throws: NetworkError.noInternet) {
            _ = try await service.searchSongs(term: "Queen", limit: 25, offset: 0)
        }
    }

    // MARK: - lookupAlbum

    @Test("lookupAlbum separates collection from tracks")
    func lookupAlbumSeparates() async throws {
        let (service, mock) = makeService()
        let fixtureURL = try #require(
            Bundle.module.url(forResource: "lookup_response", withExtension: "json", subdirectory: "Fixtures")
        )
        mock.setResponse(try Data(contentsOf: fixtureURL))

        let result = try await service.lookupAlbum(collectionId: 1440935413)

        #expect(result.collection.collectionId == 1440935413)
        #expect(result.collection.collectionName == "A Night At the Opera (Deluxe Remastered Version)")
        #expect(result.tracks.count == 2)
    }

    @Test("lookupAlbum preserves track order")
    func lookupAlbumPreservesTrackOrder() async throws {
        let (service, mock) = makeService()
        let fixtureURL = try #require(
            Bundle.module.url(forResource: "lookup_response", withExtension: "json", subdirectory: "Fixtures")
        )
        mock.setResponse(try Data(contentsOf: fixtureURL))

        let result = try await service.lookupAlbum(collectionId: 1440935413)

        #expect(result.tracks[0].trackName == "Bohemian Rhapsody")
        #expect(result.tracks[1].trackName == "Love of My Life")
    }

    @Test("lookupAlbum throws when no collection in response")
    func lookupAlbumThrowsWhenNoCollection() async {
        let (service, mock) = makeService()
        let json = """
        {
            "resultCount": 1,
            "results": [
                {
                    "wrapperType": "track",
                    "trackId": 123,
                    "trackName": "Test",
                    "artistName": "Test",
                    "artistId": 1,
                    "collectionId": 1,
                    "collectionName": "Test",
                    "trackNumber": 1,
                    "trackCount": 1,
                    "discNumber": 1,
                    "discCount": 1
                }
            ]
        }
        """
        mock.setResponse(Data(json.utf8))

        await #expect(throws: iTunesServiceError.missingCollectionInLookup) {
            _ = try await service.lookupAlbum(collectionId: 999)
        }
    }

    @Test("lookupAlbum passes correct Request")
    func lookupAlbumPassesCorrectRequest() async throws {
        let (service, mock) = makeService()
        let fixtureURL = try #require(
            Bundle.module.url(forResource: "lookup_response", withExtension: "json", subdirectory: "Fixtures")
        )
        mock.setResponse(try Data(contentsOf: fixtureURL))

        _ = try await service.lookupAlbum(collectionId: 1440935413)

        let request = try #require(mock.executedRequests.first)
        #expect(request.path == "/lookup")
        #expect(request.queryItems["id"] == "1440935413")
        #expect(request.queryItems["entity"] == "song")
    }

    @Test("lookupAlbum propagates network errors")
    func lookupAlbumPropagatesErrors() async {
        let (service, mock) = makeService()
        mock.setError(.noInternet)

        await #expect(throws: NetworkError.noInternet) {
            _ = try await service.lookupAlbum(collectionId: 1440935413)
        }
    }
}
