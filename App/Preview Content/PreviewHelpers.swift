import AppCore
import Models
import SwiftData
import SwiftUI

// MARK: - Preview Model Container

enum PreviewHelpers {

    @MainActor
    static var modelContainer: ModelContainer = {
        let schema = Schema([Song.self, Album.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        // swiftlint:disable:next force_try
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    @MainActor
    static var modelContext: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - Sample Songs

    @MainActor
    static func sampleSongs() -> [Song] {
        let context = modelContext
        let songs = [
            Song(
                trackId: 1,
                trackName: "Purple Rain",
                artistName: "Prince",
                artistId: 100,
                collectionId: 200,
                collectionName: "Purple Rain",
                trackNumber: 1,
                trackTimeMillis: 240_000
            ),
            Song(
                trackId: 2,
                trackName: "Power Of Equality",
                artistName: "Red Hot Chili Peppers",
                artistId: 101,
                collectionId: 201,
                collectionName: "Blood Sugar Sex Magik",
                trackNumber: 1,
                trackTimeMillis: 245_000
            ),
            Song(
                trackId: 3,
                trackName: "Something",
                artistName: "The Beatles",
                artistId: 102,
                collectionId: 202,
                collectionName: "Abbey Road",
                trackNumber: 4,
                trackTimeMillis: 182_000
            ),
            Song(
                trackId: 4,
                trackName: "Like A Virgin",
                artistName: "Madonna",
                artistId: 103,
                collectionId: 203,
                collectionName: "Like A Virgin",
                trackNumber: 1,
                trackTimeMillis: 218_000
            ),
            Song(
                trackId: 5,
                trackName: "Get Lucky",
                artistName: "Daft Punk feat. Pharrell Williams",
                artistId: 104,
                collectionId: 204,
                collectionName: "Random Access Memories",
                trackNumber: 8,
                trackTimeMillis: 369_000
            ),
        ]
        for song in songs {
            context.insert(song)
        }
        return songs
    }

    @MainActor
    static func sampleAlbumTracks() -> [Song] {
        let context = modelContext
        let tracks = [
            Song(trackId: 10, trackName: "Around the World", artistName: "Daft Punk",
                 artistId: 104, collectionId: 204, collectionName: "Random Access Memories",
                 trackNumber: 1, trackTimeMillis: 210_000),
            Song(trackId: 11, trackName: "Aerodynamic", artistName: "Daft Punk",
                 artistId: 104, collectionId: 204, collectionName: "Random Access Memories",
                 trackNumber: 2, trackTimeMillis: 195_000),
            Song(trackId: 12, trackName: "Harder, Better, Faster, Stronger", artistName: "Daft Punk",
                 artistId: 104, collectionId: 204, collectionName: "Random Access Memories",
                 trackNumber: 3, trackTimeMillis: 224_000),
            Song(trackId: 13, trackName: "Get Lucky", artistName: "Daft Punk feat. Pharrell Williams",
                 artistId: 104, collectionId: 204, collectionName: "Random Access Memories",
                 trackNumber: 4, trackTimeMillis: 369_000),
            Song(trackId: 14, trackName: "Digital Love", artistName: "Daft Punk",
                 artistId: 104, collectionId: 204, collectionName: "Random Access Memories",
                 trackNumber: 5, trackTimeMillis: 301_000),
            Song(trackId: 15, trackName: "One More Time", artistName: "Daft Punk",
                 artistId: 104, collectionId: 204, collectionName: "Random Access Memories",
                 trackNumber: 6, trackTimeMillis: 320_000),
        ]
        for track in tracks {
            context.insert(track)
        }
        return tracks
    }

    // MARK: - Sample Album

    @MainActor
    static func sampleAlbum() -> Album {
        let context = modelContext
        let album = Album(
            collectionId: 204,
            collectionName: "Random Access Memories",
            artistName: "Daft Punk",
            artistId: 104,
            trackCount: 6
        )
        context.insert(album)
        return album
    }

    // MARK: - Mock Repositories

    @MainActor
    static func mockSongRepository() -> any SongRepository {
        MockPreviewSongRepository()
    }

    @MainActor
    static func mockAlbumRepository() -> any AlbumRepository {
        MockPreviewAlbumRepository()
    }

    // MARK: - Preview NowPlayingManager

    @MainActor
    static func nowPlayingManager() -> NowPlayingManager {
        let audioPlayer = AudioPlayer()
        let repo = MockPreviewSongRepository()
        return NowPlayingManager(audioPlayer: audioPlayer, songRepository: repo)
    }

    @MainActor
    static func nowPlayingManagerWithSong() -> NowPlayingManager {
        let manager = nowPlayingManager()
        let songs = sampleSongs()
        if let song = songs.last {
            manager.play(song, from: songs)
            manager.audioPlayer.stop()
        }
        return manager
    }
}

// MARK: - Mock Song Repository

@MainActor
private final class MockPreviewSongRepository: SongRepository {

    nonisolated func searchSongs(term: String, limit: Int, offset: Int) async throws -> [Song] {
        await MainActor.run { PreviewHelpers.sampleSongs() }
    }

    nonisolated func recentlyPlayedSongs(limit: Int) async -> [Song] {
        await MainActor.run { PreviewHelpers.sampleSongs() }
    }

    nonisolated func markAsPlayed(_ song: Song) async throws {}
    nonisolated func toggleLike(_ song: Song) async throws {}
}

// MARK: - Mock Album Repository

@MainActor
private final class MockPreviewAlbumRepository: AlbumRepository {

    nonisolated func fetchAlbum(collectionId: Int) async throws -> AlbumWithTracks {
        await MainActor.run {
            AlbumWithTracks(
                album: PreviewHelpers.sampleAlbum(),
                tracks: PreviewHelpers.sampleAlbumTracks()
            )
        }
    }

    nonisolated func album(byCollectionId collectionId: Int) async -> Album? {
        await MainActor.run { PreviewHelpers.sampleAlbum() }
    }
}
