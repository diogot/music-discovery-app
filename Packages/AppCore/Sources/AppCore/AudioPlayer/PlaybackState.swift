import Foundation

public enum PlaybackState: Sendable {
    case idle
    case loading
    case playing
    case paused
    case failed(Error)
}

// MARK: - Equatable

extension PlaybackState: Equatable {

    public static func == (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.playing, .playing),
             (.paused, .paused),
             (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
