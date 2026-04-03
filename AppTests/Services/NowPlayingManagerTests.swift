import AppCore
import Foundation
import Models
import Testing
@testable import MusicDiscovery

@Suite("NowPlayingManager")
@MainActor
struct NowPlayingManagerTests {

    private let audioPlayer: AudioPlayer
    private let mock: MockSongRepository
    private let manager: NowPlayingManager

    init() {
        audioPlayer = AudioPlayer()
        mock = MockSongRepository()
        manager = NowPlayingManager(audioPlayer: audioPlayer, songRepository: mock)
    }

    // MARK: - Initial State

    @Test("initial state")
    func initialState() {
        #expect(manager.currentSong == nil)
        #expect(manager.playlist.isEmpty)
        #expect(manager.currentIndex == 0)
        #expect(manager.repeatMode == .off)
    }

    // MARK: - Play

    @Test("play sets current song, playlist, and index")
    func playSetsState() {
        let playlist = makePlaylist(count: 3)

        manager.play(playlist[1], from: playlist)

        #expect(manager.currentSong?.trackId == 2)
        #expect(manager.playlist.count == 3)
        #expect(manager.currentIndex == 1)
    }

    @Test("play finds correct index for song in playlist")
    func playFindsCorrectIndex() {
        let playlist = makePlaylist(count: 5)

        manager.play(playlist[3], from: playlist)

        #expect(manager.currentIndex == 3)
        #expect(manager.currentSong?.trackId == 4)
    }

    // MARK: - Forward

    @Test("forward advances to next song")
    func forwardAdvances() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[0], from: playlist)

        manager.forward()

        #expect(manager.currentSong?.trackId == 2)
        #expect(manager.currentIndex == 1)
    }

    @Test("forward at end does nothing in off mode")
    func forwardAtEndOffMode() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[2], from: playlist)

        manager.forward()

        #expect(manager.currentSong?.trackId == 3)
        #expect(manager.currentIndex == 2)
    }

    @Test("forward at end wraps in all mode")
    func forwardAtEndWrapsInAllMode() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[2], from: playlist)
        manager.repeatMode = .all

        manager.forward()

        #expect(manager.currentSong?.trackId == 1)
        #expect(manager.currentIndex == 0)
    }

    // MARK: - Backward

    @Test("backward seeks to zero when past three seconds")
    func backwardSeeksToZeroWhenPastThreeSeconds() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[1], from: playlist)
        audioPlayer.seek(to: 5.0)

        manager.backward()

        #expect(audioPlayer.currentTime == 0)
        #expect(manager.currentSong?.trackId == 2)
    }

    @Test("backward goes to previous song when at start")
    func backwardGoesToPreviousSong() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[1], from: playlist)

        manager.backward()

        #expect(manager.currentSong?.trackId == 1)
        #expect(manager.currentIndex == 0)
    }

    @Test("backward at first song seeks to zero")
    func backwardAtFirstSongSeeksToZero() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[0], from: playlist)

        manager.backward()

        #expect(audioPlayer.currentTime == 0)
        #expect(manager.currentSong?.trackId == 1)
    }

    // MARK: - Stop

    @Test("stop clears all state")
    func stopClearsState() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[0], from: playlist)

        manager.stop()

        #expect(manager.currentSong == nil)
        #expect(manager.playlist.isEmpty)
        #expect(manager.currentIndex == 0)
        #expect(audioPlayer.playbackState == .idle)
    }

    // MARK: - Repeat Mode

    @Test("cycleRepeatMode cycles off → all → one → off")
    func cycleRepeatMode() {
        #expect(manager.repeatMode == .off)

        manager.cycleRepeatMode()
        #expect(manager.repeatMode == .all)

        manager.cycleRepeatMode()
        #expect(manager.repeatMode == .one)

        manager.cycleRepeatMode()
        #expect(manager.repeatMode == .off)
    }

    // MARK: - handleSongEnd (via onPlaybackEnd)

    @Test("song end with repeat-one replays same song")
    func songEndRepeatOneReplays() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[0], from: playlist)
        manager.repeatMode = .one

        audioPlayer.onPlaybackEnd?()

        #expect(manager.currentSong?.trackId == 1)
        #expect(manager.currentIndex == 0)
    }

    @Test("song end with repeat-all wraps to first")
    func songEndRepeatAllWraps() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[2], from: playlist)
        manager.repeatMode = .all

        audioPlayer.onPlaybackEnd?()

        #expect(manager.currentSong?.trackId == 1)
        #expect(manager.currentIndex == 0)
    }

    @Test("song end with repeat-all advances to next when not at end")
    func songEndRepeatAllAdvancesMiddle() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[0], from: playlist)
        manager.repeatMode = .all

        audioPlayer.onPlaybackEnd?()

        #expect(manager.currentSong?.trackId == 2)
        #expect(manager.currentIndex == 1)
    }

    @Test("song end with repeat-off advances to next")
    func songEndOffAdvances() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[0], from: playlist)

        audioPlayer.onPlaybackEnd?()

        #expect(manager.currentSong?.trackId == 2)
        #expect(manager.currentIndex == 1)
    }

    @Test("song end with repeat-off at last song does not wrap")
    func songEndOffAtEndStops() {
        let playlist = makePlaylist(count: 3)
        manager.play(playlist[2], from: playlist)

        audioPlayer.onPlaybackEnd?()

        #expect(manager.currentSong?.trackId == 3)
        #expect(manager.currentIndex == 2)
    }

    // MARK: - Toggle Like

    @Test("toggleLike calls repository")
    func toggleLikeCallsRepository() async {
        let song = makeSong()
        manager.play(song, from: [song])

        manager.toggleLike()
        try? await Task.sleep(for: .milliseconds(100))

        #expect(mock.toggleLikeCalls.count == 1)
        #expect(mock.toggleLikeCalls[0].trackId == song.trackId)
    }
}
