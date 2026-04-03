import Foundation
import Models
import SwiftData
import Testing
@testable import MusicDiscovery

@Suite("AlbumViewModel")
@MainActor
struct AlbumViewModelTests {

    private let mock: MockAlbumRepository
    private let viewModel: AlbumViewModel

    init() {
        mock = MockAlbumRepository()
        viewModel = AlbumViewModel(albumRepository: mock)
    }

    // MARK: - Initial State

    @Test("initial state")
    func initialState() {
        #expect(viewModel.albumWithTracks == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    // MARK: - Load Album

    @Test("loadAlbum sets albumWithTracks on success")
    func loadAlbumSuccess() async throws {
        let album = Album(
            collectionId: 42,
            collectionName: "Test Album",
            artistName: "Artist",
            artistId: 1
        )
        let tracks = [makeSong(trackId: 1), makeSong(trackId: 2)]
        mock.fetchAlbumResult = .success(AlbumWithTracks(album: album, tracks: tracks))

        viewModel.loadAlbum(collectionId: 42)
        try await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.albumWithTracks != nil)
        #expect(viewModel.albumWithTracks?.album.collectionId == 42)
        #expect(viewModel.albumWithTracks?.tracks.count == 2)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
        #expect(mock.fetchAlbumCalls == [42])
    }

    @Test("loadAlbum sets error on failure")
    func loadAlbumError() async throws {
        mock.fetchAlbumResult = .failure(URLError(.badServerResponse))

        viewModel.loadAlbum(collectionId: 1)
        try await Task.sleep(for: .milliseconds(50))

        #expect(viewModel.error != nil)
        #expect(viewModel.albumWithTracks == nil)
        #expect(viewModel.isLoading == false)
        #expect(mock.fetchAlbumCalls == [1])

    }

    @Test("loadAlbum passes correct collectionId")
    func loadAlbumPassesCollectionId() async throws {
        mock.fetchAlbumResult = .success(
            AlbumWithTracks(
                album: Album(collectionId: 99, collectionName: "A", artistName: "B", artistId: 1),
                tracks: []
            )
        )

        viewModel.loadAlbum(collectionId: 99)
        try await Task.sleep(for: .milliseconds(50))

        #expect(mock.fetchAlbumCalls == [99])
    }

    @Test("loadAlbum ignores duplicate call while loading")
    func loadAlbumIgnoresDuplicate() async throws {
        mock.fetchAlbumResult = .success(
            AlbumWithTracks(
                album: Album(collectionId: 1, collectionName: "A", artistName: "B", artistId: 1),
                tracks: []
            )
        )

        viewModel.loadAlbum(collectionId: 1)
        viewModel.loadAlbum(collectionId: 1)
        try await Task.sleep(for: .milliseconds(50))

        #expect(mock.fetchAlbumCalls.count == 1)
    }
}
