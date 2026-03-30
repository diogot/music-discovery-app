import Foundation
import SwiftData
import Testing
@testable import Models

@Suite("Song Persistence")
struct SongPersistenceTests {

    private let container: ModelContainer

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Song.self, Album.self, configurations: config)
    }

    @Test("insert and fetch")
    func insertAndFetch() throws {
        let context = ModelContext(container)
        let song = Song(
            trackId: 123,
            trackName: "Get Lucky",
            artistName: "Daft Punk",
            artistId: 456,
            collectionId: 789,
            collectionName: "Random Access Memories",
            trackNumber: 8,
            trackTimeMillis: 369_000
        )
        context.insert(song)
        try context.save()

        let descriptor = FetchDescriptor<Song>()
        let results = try context.fetch(descriptor)

        #expect(results.count == 1)
        #expect(results[0].trackId == 123)
        #expect(results[0].trackName == "Get Lucky")
        #expect(results[0].trackTimeMillis == 369_000)
    }

    @Test("unique constraint upserts on trackId")
    func uniqueConstraintUpsert() throws {
        let context = ModelContext(container)

        let song1 = Song(
            trackId: 100,
            trackName: "Original",
            artistName: "Artist",
            artistId: 1,
            collectionId: 2,
            collectionName: "Album"
        )
        context.insert(song1)
        try context.save()

        let song2 = Song(
            trackId: 100,
            trackName: "Updated",
            artistName: "Artist",
            artistId: 1,
            collectionId: 2,
            collectionName: "Album"
        )
        context.insert(song2)
        try context.save()

        let descriptor = FetchDescriptor<Song>()
        let results = try context.fetch(descriptor)

        #expect(results.count == 1)
    }

    @Test("update lastPlayedAt persists")
    func updateLastPlayedAt() throws {
        let context = ModelContext(container)
        let song = Song(
            trackId: 1,
            trackName: "Test",
            artistName: "Artist",
            artistId: 2,
            collectionId: 3,
            collectionName: "Album"
        )
        context.insert(song)
        try context.save()

        let now = Date()
        song.lastPlayedAt = now
        try context.save()

        let descriptor = FetchDescriptor<Song>()
        let results = try context.fetch(descriptor)

        #expect(results[0].lastPlayedAt != nil)
    }

    @Test("fetch sorted by lastPlayedAt descending")
    func fetchSortedByLastPlayedAt() throws {
        let context = ModelContext(container)

        let old = Song(
            trackId: 1,
            trackName: "Old",
            artistName: "A",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album",
            lastPlayedAt: Date(timeIntervalSince1970: 1_000)
        )
        let recent = Song(
            trackId: 2,
            trackName: "Recent",
            artistName: "A",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album",
            lastPlayedAt: Date(timeIntervalSince1970: 3_000)
        )
        let middle = Song(
            trackId: 3,
            trackName: "Middle",
            artistName: "A",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album",
            lastPlayedAt: Date(timeIntervalSince1970: 2_000)
        )

        context.insert(old)
        context.insert(recent)
        context.insert(middle)
        try context.save()

        var descriptor = FetchDescriptor<Song>(
            sortBy: [SortDescriptor(\.lastPlayedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 3
        let results = try context.fetch(descriptor)

        #expect(results.count == 3)
        #expect(results[0].trackName == "Recent")
        #expect(results[1].trackName == "Middle")
        #expect(results[2].trackName == "Old")
    }

    @Test("predicate filters by collectionId")
    func predicateByCollectionId() throws {
        let context = ModelContext(container)

        let songA = Song(
            trackId: 1,
            trackName: "Track A",
            artistName: "A",
            artistId: 1,
            collectionId: 100,
            collectionName: "Album A"
        )
        let songB = Song(
            trackId: 2,
            trackName: "Track B",
            artistName: "A",
            artistId: 1,
            collectionId: 200,
            collectionName: "Album B"
        )
        let songC = Song(
            trackId: 3,
            trackName: "Track C",
            artistName: "A",
            artistId: 1,
            collectionId: 100,
            collectionName: "Album A"
        )

        context.insert(songA)
        context.insert(songB)
        context.insert(songC)
        try context.save()

        let targetId = 100
        let descriptor = FetchDescriptor<Song>(
            predicate: #Predicate { $0.collectionId == targetId }
        )
        let results = try context.fetch(descriptor)

        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.collectionId == 100 })
    }

    @Test("delete removes song")
    func deleteRemoves() throws {
        let context = ModelContext(container)
        let song = Song(
            trackId: 1,
            trackName: "Test",
            artistName: "A",
            artistId: 1,
            collectionId: 1,
            collectionName: "Album"
        )
        context.insert(song)
        try context.save()

        context.delete(song)
        try context.save()

        let descriptor = FetchDescriptor<Song>()
        let results = try context.fetch(descriptor)
        #expect(results.isEmpty)
    }
}
