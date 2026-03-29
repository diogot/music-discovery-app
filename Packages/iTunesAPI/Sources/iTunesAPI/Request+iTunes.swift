import NetworkService

extension Request {
    static func searchSongs(term: String, limit: Int, offset: Int) -> Request {
        Request(
            path: "/search",
            queryItems: [
                "term": term,
                "media": "music",
                "entity": "song",
                "limit": String(limit),
                "offset": String(offset),
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
