import Foundation
import iTunesAPI
import Models
import SwiftData

enum SongUpserter {

    /// Upserts songs from DTOs using fetch-then-update to preserve local-only
    /// fields (`isLiked`, `lastPlayedAt`). Saves the context once at the end.
    @MainActor
    static func upsert(_ dtos: [TrackDTO], in context: ModelContext) throws -> [Song] {
        var songs: [Song] = []

        for dto in dtos {
            let trackId = dto.trackId
            var descriptor = FetchDescriptor<Song>(
                predicate: #Predicate { $0.trackId == trackId }
            )
            descriptor.fetchLimit = 1

            if let existing = try context.fetch(descriptor).first {
                existing.update(from: dto)
                songs.append(existing)
            } else {
                let song = Song.from(dto)
                context.insert(song)
                songs.append(song)
            }
        }

        try context.save()
        return songs
    }
}
