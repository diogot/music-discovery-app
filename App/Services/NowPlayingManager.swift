import AppCore
import Foundation
import Models
import Observation

@Observable
@MainActor
final class NowPlayingManager {

    // MARK: - Observable State

    private(set) var currentSong: Song?
    private(set) var playlist: [Song] = []
    private(set) var currentIndex: Int = 0

    let audioPlayer: AudioPlayer

    // MARK: - Private

    private let songRepository: any SongRepository

    // MARK: - Init

    init(audioPlayer: AudioPlayer, songRepository: any SongRepository) {
        self.audioPlayer = audioPlayer
        self.songRepository = songRepository
    }

    // MARK: - Playback

    func play(_ song: Song, from playlist: [Song]) {
        self.playlist = playlist
        self.currentIndex = playlist.firstIndex(where: { $0.trackId == song.trackId }) ?? 0
        self.currentSong = song
        guard let previewURL = song.previewURL else { return }
        audioPlayer.play(url: previewURL)
        Task { try? await songRepository.markAsPlayed(song) }
    }

    func togglePlayPause() {
        switch audioPlayer.playbackState {
        case .playing:
            audioPlayer.pause()
        case .paused:
            audioPlayer.resume()
        case .idle:
            if let url = currentSong?.previewURL {
                audioPlayer.play(url: url)
            }
        default:
            break
        }
    }

    func forward() {
        guard currentIndex + 1 < playlist.count else { return }
        play(playlist[currentIndex + 1], from: playlist)
    }

    func backward() {
        if audioPlayer.currentTime > 3 {
            audioPlayer.seek(to: 0)
        } else if currentIndex > 0 {
            play(playlist[currentIndex - 1], from: playlist)
        } else {
            audioPlayer.seek(to: 0)
        }
    }

    func stop() {
        audioPlayer.stop()
        currentSong = nil
        playlist = []
        currentIndex = 0
    }

    func seek(to time: TimeInterval) {
        audioPlayer.seek(to: time)
    }

    func toggleLike() {
        guard let song = currentSong else { return }
        Task { try? await songRepository.toggleLike(song) }
    }
}
