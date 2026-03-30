import Foundation
import SwiftData
import Testing
@testable import Models

@Suite("Album Persistence")
struct AlbumPersistenceTests {

    private let container: ModelContainer

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Song.self, Album.self, configurations: config)
    }

    @Test("insert and fetch")
    func insertAndFetch() throws {
        let context = ModelContext(container)
        let album = Album(
            collectionId: 789,
            collectionName: "Random Access Memories",
            artistName: "Daft Punk",
            artistId: 456,
            trackCount: 13,
            genre: "Electronic",
            copyright: "℗ 2013 Daft Life Limited"
        )
        context.insert(album)
        try context.save()

        let descriptor = FetchDescriptor<Album>()
        let results = try context.fetch(descriptor)

        #expect(results.count == 1)
        #expect(results[0].collectionId == 789)
        #expect(results[0].collectionName == "Random Access Memories")
        #expect(results[0].trackCount == 13)
        #expect(results[0].copyright == "℗ 2013 Daft Life Limited")
    }

    @Test("unique constraint upserts on collectionId")
    func uniqueConstraintUpsert() throws {
        let context = ModelContext(container)

        let album1 = Album(
            collectionId: 100,
            collectionName: "Original",
            artistName: "Artist",
            artistId: 1
        )
        context.insert(album1)
        try context.save()

        let album2 = Album(
            collectionId: 100,
            collectionName: "Updated",
            artistName: "Artist",
            artistId: 1
        )
        context.insert(album2)
        try context.save()

        let descriptor = FetchDescriptor<Album>()
        let results = try context.fetch(descriptor)

        #expect(results.count == 1)
    }

    @Test("delete removes album")
    func deleteRemoves() throws {
        let context = ModelContext(container)
        let album = Album(
            collectionId: 1,
            collectionName: "Test",
            artistName: "Artist",
            artistId: 1
        )
        context.insert(album)
        try context.save()

        context.delete(album)
        try context.save()

        let descriptor = FetchDescriptor<Album>()
        let results = try context.fetch(descriptor)
        #expect(results.isEmpty)
    }
}
