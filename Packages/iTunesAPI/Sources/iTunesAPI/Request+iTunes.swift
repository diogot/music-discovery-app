import NetworkService

extension Request {
    static func searchSongs(term: String, limit: Int) -> Request {
        Request(
            path: "/search",
            queryItems: [
                "term": term,
                "media": "music",
                "entity": "song",
                "limit": String(limit),
            ]
        )
    }

    static func lookupAlbumTracks(collectionId: Int) -> Request {
        Request(
            path: "/lookup",
            queryItems: [
                "id": String(collectionId),
                "entity": "song",
            ]
        )
    }
}
