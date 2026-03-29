import Foundation
import Testing
@testable import iTunesAPI

@Suite("TrackDTO")
struct TrackDTOTests {
    @Test("Decodes complete track with all fields")
    func decodesCompleteTrack() throws {
        let json = """
        {
            "trackId": 1440935467,
            "trackName": "Bohemian Rhapsody",
            "artistName": "Queen",
            "artistId": 3296287,
            "collectionId": 1440935413,
            "collectionName": "A Night At the Opera",
            "trackNumber": 11,
            "trackCount": 17,
            "discNumber": 1,
            "discCount": 1,
            "trackTimeMillis": 354947,
            "previewUrl": "https://example.com/preview.m4a",
            "artworkUrl100": "https://example.com/artwork.jpg",
            "releaseDate": "1975-10-31T07:00:00Z",
            "primaryGenreName": "Rock"
        }
        """

        let track = try JSONDecoder().decode(TrackDTO.self, from: Data(json.utf8))

        #expect(track.trackId == 1440935467)
        #expect(track.trackName == "Bohemian Rhapsody")
        #expect(track.artistName == "Queen")
        #expect(track.artistId == 3296287)
        #expect(track.collectionId == 1440935413)
        #expect(track.collectionName == "A Night At the Opera")
        #expect(track.trackNumber == 11)
        #expect(track.trackCount == 17)
        #expect(track.discNumber == 1)
        #expect(track.discCount == 1)
        #expect(track.trackTimeMillis == 354947)
        #expect(track.previewUrl == "https://example.com/preview.m4a")
        #expect(track.artworkUrl100 == "https://example.com/artwork.jpg")
        #expect(track.releaseDate == "1975-10-31T07:00:00Z")
        #expect(track.primaryGenreName == "Rock")
    }

    @Test("Decodes track with nil optionals")
    func decodesTrackWithNilOptionals() throws {
        let json = """
        {
            "trackId": 123,
            "trackName": "Test Song",
            "artistName": "Test Artist",
            "artistId": 456,
            "collectionId": 789,
            "collectionName": "Test Album",
            "trackNumber": 1,
            "trackCount": 10,
            "discNumber": 1,
            "discCount": 1
        }
        """

        let track = try JSONDecoder().decode(TrackDTO.self, from: Data(json.utf8))

        #expect(track.trackId == 123)
        #expect(track.trackTimeMillis == nil)
        #expect(track.previewUrl == nil)
        #expect(track.artworkUrl100 == nil)
        #expect(track.releaseDate == nil)
        #expect(track.primaryGenreName == nil)
    }
}
