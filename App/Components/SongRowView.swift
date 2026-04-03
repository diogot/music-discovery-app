import Models
import SwiftData
import SwiftUI

struct SongRowView: View {

    let song: Song
    var showMoreButton = true
    var onMoreTapped: (() -> Void)?

    var body: some View {
        HStack(spacing: 16) {
            ArtworkView(
                url: song.artworkURL,
                size: Theme.Sizing.songRowArtwork
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(song.trackName)
                    .font(Theme.Fonts.display(16))
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .lineLimit(1)

                Text(song.artistName)
                    .font(Theme.Fonts.text(14))
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            if showMoreButton {
                Button {
                    onMoreTapped?()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let songs = PreviewHelpers.sampleSongs()
    List {
        ForEach(songs, id: \.trackId) { song in
            SongRowView(song: song) {}
                .listRowBackground(Theme.Colors.background)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
    }
    .listStyle(.plain)
    .listRowSpacing(0)
    .scrollContentBackground(.hidden)
    .background(Theme.Colors.background)
    .modelContainer(PreviewHelpers.modelContainer)
    .preferredColorScheme(.dark)
}
