public struct AlbumWithTracks {

    public let album: Album
    public let tracks: [Song]

    public init(album: Album, tracks: [Song]) {
        self.album = album
        self.tracks = tracks
    }
}
