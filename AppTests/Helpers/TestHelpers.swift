import Foundation
import Models

@MainActor
func makeSong(
    trackId: Int = 1,
    trackName: String = "Test Song",
    artistName: String = "Test Artist",
    artistId: Int = 1,
    collectionId: Int = 100,
    collectionName: String = "Test Album",
    trackNumber: Int = 1,
    previewURL: URL? = nil
) -> Song {
    Song(
        trackId: trackId,
        trackName: trackName,
        artistName: artistName,
        artistId: artistId,
        collectionId: collectionId,
        collectionName: collectionName,
        trackNumber: trackNumber,
        previewURL: previewURL
    )
}

@MainActor
func makePlaylist(count: Int = 3) -> [Song] {
    (1...count).map { index in
        makeSong(
            trackId: index,
            trackName: "Song \(index)",
            trackNumber: index
        )
    }
}
