import Foundation
import Testing
@testable import iTunesAPI

@Suite("LookupResultItem")
struct LookupResultItemTests {
    @Test("wrapperType collection decodes to .collection")
    func decodesCollection() throws {
        let json = """
        {
            "wrapperType": "collection",
            "collectionId": 1440935413,
            "collectionName": "A Night At the Opera",
            "artistName": "Queen",
            "artistId": 3296287,
            "trackCount": 17
        }
        """

        let item = try JSONDecoder().decode(LookupResultItem.self, from: Data(json.utf8))

        guard case .collection(let dto) = item else {
            Issue.record("Expected .collection, got \(item)")
            return
        }
        #expect(dto.collectionId == 1440935413)
        #expect(dto.collectionName == "A Night At the Opera")
    }

    @Test("wrapperType track decodes to .track")
    func decodesTrack() throws {
        let json = """
        {
            "wrapperType": "track",
            "trackId": 1440935467,
            "trackName": "Bohemian Rhapsody",
            "artistName": "Queen",
            "artistId": 3296287,
            "collectionId": 1440935413,
            "collectionName": "A Night At the Opera",
            "trackNumber": 11,
            "trackCount": 17,
            "discNumber": 1,
            "discCount": 1
        }
        """

        let item = try JSONDecoder().decode(LookupResultItem.self, from: Data(json.utf8))

        guard case .track(let dto) = item else {
            Issue.record("Expected .track, got \(item)")
            return
        }
        #expect(dto.trackId == 1440935467)
        #expect(dto.trackName == "Bohemian Rhapsody")
    }

    @Test("Unknown wrapperType throws DecodingError")
    func unknownWrapperTypeThrows() {
        let json = """
        {
            "wrapperType": "artist",
            "artistId": 3296287
        }
        """

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(LookupResultItem.self, from: Data(json.utf8))
        }
    }

    @Test("Full mixed array decodes correctly")
    func fullMixedArray() throws {
        let url = try #require(
            Bundle.module.url(forResource: "lookup_response", withExtension: "json", subdirectory: "Fixtures")
        )
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(iTunesSearchResponse<LookupResultItem>.self, from: data)

        #expect(response.resultCount == 3)
        #expect(response.results.count == 3)

        guard case .collection = response.results[0] else {
            Issue.record("Expected first item to be .collection")
            return
        }
        guard case .track = response.results[1] else {
            Issue.record("Expected second item to be .track")
            return
        }
        guard case .track = response.results[2] else {
            Issue.record("Expected third item to be .track")
            return
        }
    }
}
