import Testing
import NetworkService
@testable import iTunesAPI

@Suite("Request+iTunes")
struct RequestiTunesTests {
    @Test("searchSongs produces correct path, method, and query items")
    func searchSongs() {
        let request = Request.searchSongs(term: "Queen", limit: 25)

        #expect(request.method == .get)
        #expect(request.path == "/search")
        #expect(request.queryItems["term"] == "Queen")
        #expect(request.queryItems["media"] == "music")
        #expect(request.queryItems["entity"] == "song")
        #expect(request.queryItems["limit"] == "25")
        #expect(request.queryItems.count == 4)
    }

    @Test("lookupAlbumTracks produces correct path and query items")
    func lookupAlbumTracks() {
        let request = Request.lookupAlbumTracks(collectionId: 1440935413)

        #expect(request.method == .get)
        #expect(request.path == "/lookup")
        #expect(request.queryItems["id"] == "1440935413")
        #expect(request.queryItems["entity"] == "song")
        #expect(request.queryItems.count == 2)
    }
}
