import SwiftUI

enum Theme {

    // MARK: - Colors

    enum Colors {
        static let background = Color.black
        static let textPrimary = Color.white
        static let textSecondary = Color(white: 0.66)
        static let textTertiary = Color(white: 0.45)
        static let sliderTrack = Color(white: 0.33)
        static let accent = Color.orange
        static let sheetBackground = Color(white: 0.15).opacity(0.8)
    }

    // MARK: - Fonts (Articulat CF — embedded)

    enum Fonts {
        private static let demiBold = "ArticulatCF-DemiBold"
        private static let medium = "ArticulatCF-Medium"

        static func display(_ size: CGFloat) -> Font {
            .custom(demiBold, size: size)
        }

        static func text(_ size: CGFloat) -> Font {
            .custom(medium, size: size)
        }

        static func mono(_ size: CGFloat) -> Font {
            .custom("TestSohneMono-Kraftig", size: size)
        }
    }

    // MARK: - Sizing

    enum Sizing {
        static let songRowArtwork: CGFloat = 52
        static let playerArtwork: CGFloat = 280
        static let albumHeaderArtwork: CGFloat = 150
        static let albumTrackArtwork: CGFloat = 40
        static let artworkCornerRadius: CGFloat = 8
        static let playerArtworkCornerRadius: CGFloat = 32
    }
}
