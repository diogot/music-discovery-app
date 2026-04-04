import NetworkService

public protocol iTunesService: Sendable {
    func searchSongs(term: String, limit: Int) async throws -> [TrackDTO]
    func lookupAlbum(collectionId: Int) async throws -> AlbumLookupResult
}

public struct AlbumLookupResult: Sendable {
    public let collection: CollectionDTO
    public let tracks: [TrackDTO]

    public init(collection: CollectionDTO, tracks: [TrackDTO]) {
        self.collection = collection
        self.tracks = tracks
    }
}

public enum iTunesServiceError: Error, Sendable {
    case missingCollectionInLookup
}

public struct LiveiTunesService: iTunesService {
    private let networkService: any NetworkService

    public init(networkService: any NetworkService) {
        self.networkService = networkService
    }

    public func searchSongs(term: String, limit: Int) async throws -> [TrackDTO] {
        let request = Request.searchSongs(term: term, limit: limit)
        let response: iTunesSearchResponse<TrackDTO> = try await networkService.execute(request)
        return response.results
    }

    public func lookupAlbum(collectionId: Int) async throws -> AlbumLookupResult {
        let request = Request.lookupAlbumTracks(collectionId: collectionId)
        let response: iTunesSearchResponse<LookupResultItem> = try await networkService.execute(request)

        var collection: CollectionDTO?
        var tracks: [TrackDTO] = []

        for item in response.results {
            switch item {
            case .collection(let dto):
                collection = dto
            case .track(let dto):
                tracks.append(dto)
            }
        }

        guard let collection else {
            throw iTunesServiceError.missingCollectionInLookup
        }

        return AlbumLookupResult(collection: collection, tracks: tracks)
    }
}
