import Kingfisher
import SwiftUI

struct ArtworkView: View {

    let url: URL?
    let size: CGFloat
    var cornerRadius: CGFloat = Theme.Sizing.artworkCornerRadius

    var body: some View {
        KFImage(url)
            .placeholder { placeholder }
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var placeholder: some View {
        ZStack {
            Color(white: 0.15)
            Image(systemName: "music.note")
                .font(.system(size: size * 0.3))
                .foregroundStyle(Theme.Colors.textTertiary)
        }
    }
}

#Preview("With URL") {
    ArtworkView(url: URL(string: "https://picsum.photos/100"), size: 52)
}

#Preview("Placeholder") {
    ArtworkView(url: nil, size: 52)
        .preferredColorScheme(.dark)
}
