import Foundation
import iTunesAPI
import Models
import SwiftData

public final class SwiftDataSongRepository: SongRepository {

    private let iTunesService: any iTunesService
    private let modelContext: ModelContext

    init(iTunesService: any iTunesService, modelContext: ModelContext) {
        self.iTunesService = iTunesService
        self.modelContext = modelContext
    }

    public func searchSongs(term: String, limit: Int, offset: Int) async throws -> [Song] {
        let dtos = try await iTunesService.searchSongs(term: term, limit: limit, offset: offset)
        return try SongUpserter.upsert(dtos, in: modelContext)
    }

    public func recentlyPlayedSongs(limit: Int) async -> [Song] {
        var descriptor = FetchDescriptor<Song>(
            predicate: #Predicate { $0.lastPlayedAt != nil },
            sortBy: [SortDescriptor(\.lastPlayedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    public func markAsPlayed(_ song: Song) async throws {
        song.lastPlayedAt = Date()
        try modelContext.save()
    }

    public func toggleLike(_ song: Song) async throws {
        song.isLiked.toggle()
        try modelContext.save()
    }
}
