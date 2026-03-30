import Foundation
import iTunesAPI
import Models
import SwiftData

@MainActor
public final class SwiftDataAlbumRepository: @preconcurrency AlbumRepository {

    private let iTunesService: any iTunesService
    private let modelContext: ModelContext

    init(iTunesService: any iTunesService, modelContext: ModelContext) {
        self.iTunesService = iTunesService
        self.modelContext = modelContext
    }

    public func fetchAlbum(collectionId: Int) async throws -> AlbumWithTracks {
        let result = try await iTunesService.lookupAlbum(collectionId: collectionId)

        let album = try upsertAlbum(from: result.collection)
        let tracks = try SongUpserter.upsert(result.tracks, in: modelContext)

        let sorted = tracks.sorted {
            ($0.discNumber, $0.trackNumber) < ($1.discNumber, $1.trackNumber)
        }

        return AlbumWithTracks(album: album, tracks: sorted)
    }

    public func album(byCollectionId collectionId: Int) async -> Album? {
        var descriptor = FetchDescriptor<Album>(
            predicate: #Predicate { $0.collectionId == collectionId }
        )
        descriptor.fetchLimit = 1
        return try? modelContext.fetch(descriptor).first
    }

    // MARK: - Private

    private func upsertAlbum(from dto: CollectionDTO) throws -> Album {
        let collectionId = dto.collectionId
        var descriptor = FetchDescriptor<Album>(
            predicate: #Predicate { $0.collectionId == collectionId }
        )
        descriptor.fetchLimit = 1

        if let existing = try modelContext.fetch(descriptor).first {
            existing.update(from: dto)
            try modelContext.save()
            return existing
        } else {
            let album = Album.from(dto)
            modelContext.insert(album)
            try modelContext.save()
            return album
        }
    }
}
