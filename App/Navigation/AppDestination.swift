import Foundation
import Models

enum AppDestination: Hashable {
    case player
    case album(collectionId: Int)
}

// MARK: - Player Navigation

extension Array where Element == AppDestination {

    @MainActor
    mutating func navigateToPlayer(
        playing song: Song,
        from playlist: [Song],
        using manager: NowPlayingManager
    ) {
        manager.play(song, from: playlist)
        if let playerIndex = firstIndex(of: .player) {
            removeSubrange((playerIndex + 1)...)
        } else {
            append(.player)
        }
    }
}
