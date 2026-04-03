import AppCore
import Foundation
import Models
import Observation

enum RepeatMode: CaseIterable {
    case off
    case all
    case one
}

@Observable
@MainActor
final class NowPlayingManager {

    // MARK: - Observable State

    private(set) var currentSong: Song?
    private(set) var playlist: [Song] = []
    private(set) var currentIndex: Int = 0
    var repeatMode: RepeatMode = .off

    let audioPlayer: AudioPlayer

    // MARK: - Private

    private let songRepository: any SongRepository

    // MARK: - Init

    init(audioPlayer: AudioPlayer, songRepository: any SongRepository) {
        self.audioPlayer = audioPlayer
        self.songRepository = songRepository
        audioPlayer.onPlaybackEnd = { [weak self] in
            self?.handleSongEnd()
        }
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
        let nextIndex = currentIndex + 1
        if nextIndex < playlist.count {
            play(playlist[nextIndex], from: playlist)
        } else if repeatMode == .all, !playlist.isEmpty {
            play(playlist[0], from: playlist)
        }
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

    func cycleRepeatMode() {
        let modes = RepeatMode.allCases
        guard let index = modes.firstIndex(of: repeatMode) else { return }
        repeatMode = modes[(index + 1) % modes.count]
    }

    // MARK: - Private

    private func handleSongEnd() {
        switch repeatMode {
        case .one:
            if let url = currentSong?.previewURL {
                audioPlayer.play(url: url)
            }
        case .all:
            let nextIndex = currentIndex + 1
            if nextIndex < playlist.count {
                play(playlist[nextIndex], from: playlist)
            } else if !playlist.isEmpty {
                play(playlist[0], from: playlist)
            }
        case .off:
            let nextIndex = currentIndex + 1
            if nextIndex < playlist.count {
                play(playlist[nextIndex], from: playlist)
            }
        }
    }
}
