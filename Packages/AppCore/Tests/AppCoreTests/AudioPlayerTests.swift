import Foundation
import Testing
@testable import AppCore

@Suite("AudioPlayer")
@MainActor
struct AudioPlayerTests {

    @Test("initial state is idle")
    func initialState() {
        let player = AudioPlayer()

        #expect(player.playbackState == .idle)
        #expect(player.currentTime == 0)
        #expect(player.duration == 0)
    }

    @Test("stop resets to idle")
    func stopResetsState() {
        let player = AudioPlayer()
        player.stop()

        #expect(player.playbackState == .idle)
        #expect(player.currentTime == 0)
        #expect(player.duration == 0)
    }

    @Test("pause when not playing does nothing")
    func pauseWhenNotPlaying() {
        let player = AudioPlayer()
        player.pause()

        #expect(player.playbackState == .idle)
    }

    @Test("resume when not paused does nothing")
    func resumeWhenNotPaused() {
        let player = AudioPlayer()
        player.resume()

        #expect(player.playbackState == .idle)
    }

    @Test("seek updates currentTime")
    func seekUpdatesTime() {
        let player = AudioPlayer()
        player.seek(to: 15.5)

        #expect(player.currentTime == 15.5)
    }
}
