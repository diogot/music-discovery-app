import Foundation
import Testing
@testable import iTunesAPI

@Suite("CollectionDTO")
struct CollectionDTOTests {
    @Test("Decodes complete collection")
    func decodesCompleteCollection() throws {
        let json = """
        {
            "collectionId": 1440935413,
            "collectionName": "A Night At the Opera",
            "artistName": "Queen",
            "artistId": 3296287,
            "artworkUrl100": "https://example.com/artwork.jpg",
            "trackCount": 17,
            "releaseDate": "1975-10-31T07:00:00Z",
            "primaryGenreName": "Rock",
            "copyright": "℗ 2011 Hollywood Records, Inc."
        }
        """

        let collection = try JSONDecoder().decode(CollectionDTO.self, from: Data(json.utf8))

        #expect(collection.collectionId == 1440935413)
        #expect(collection.collectionName == "A Night At the Opera")
        #expect(collection.artistName == "Queen")
        #expect(collection.artistId == 3296287)
        #expect(collection.artworkUrl100 == "https://example.com/artwork.jpg")
        #expect(collection.trackCount == 17)
        #expect(collection.releaseDate == "1975-10-31T07:00:00Z")
        #expect(collection.primaryGenreName == "Rock")
        #expect(collection.copyright == "℗ 2011 Hollywood Records, Inc.")
    }

    @Test("Decodes collection with nil optionals")
    func decodesCollectionWithNilOptionals() throws {
        let json = """
        {
            "collectionId": 100,
            "collectionName": "Test Album",
            "artistName": "Test Artist",
            "artistId": 200,
            "trackCount": 5
        }
        """

        let collection = try JSONDecoder().decode(CollectionDTO.self, from: Data(json.utf8))

        #expect(collection.collectionId == 100)
        #expect(collection.artworkUrl100 == nil)
        #expect(collection.releaseDate == nil)
        #expect(collection.primaryGenreName == nil)
        #expect(collection.copyright == nil)
    }
}
