import Models
import SwiftData
import SwiftUI

struct MoreOptionsSheet: View {

    let song: Song
    let onViewAlbum: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            songHeader
                .padding(.top, 16)
                .padding(.bottom, 16)

            Divider()
                .overlay(Color.white.opacity(0.15))

            albumAction
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .glassEffect(.regular)
        .presentationDetents([.height(200)])
        .presentationDragIndicator(.visible)
        .presentationBackground(.clear)
    }

    // MARK: - Song Header

    private var songHeader: some View {
        VStack(spacing: 4) {
            Text(song.trackName)
                .font(Theme.Fonts.display(18))
                .foregroundStyle(Theme.Colors.textPrimary)
                .lineLimit(1)

            Text(song.artistName)
                .font(Theme.Fonts.text(14))
                .foregroundStyle(Theme.Colors.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Album Action

    private var albumAction: some View {
        Button {
            dismiss()
            onViewAlbum()
        } label: {
            HStack(spacing: 16) {
                Image(.Player.icSetlist)
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .frame(width: 24, height: 24)

                Text(.moreOptionsViewAlbumButton)
                    .font(Theme.Fonts.text(16))
                    .foregroundStyle(Theme.Colors.textPrimary)

                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MoreOptionsSheet(song: PreviewHelpers.sampleSongs().last!) {}
        .modelContainer(PreviewHelpers.modelContainer)
        .preferredColorScheme(.dark)
}
