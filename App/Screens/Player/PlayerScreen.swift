import AppCore
import Models
import SwiftData
import SwiftUI

struct PlayerScreen: View {

    @Environment(NowPlayingManager.self) private var nowPlayingManager
    @Binding var path: [AppDestination]
    @State private var showMoreOptions = false
    @State private var isSeeking = false
    @State private var seekTime: TimeInterval = 0

    var body: some View {
        let audioPlayer = nowPlayingManager.audioPlayer

        VStack(spacing: 0) {
            Spacer()

            artwork

            Spacer()

            songInfo

            timeline(audioPlayer: audioPlayer)

            playbackControls(audioPlayer: audioPlayer)

            Spacer()
                .frame(height: 40)
        }
        .padding(.horizontal, 24)
        .background(Theme.Colors.background)
        .navigationTitle(nowPlayingManager.currentSong?.collectionName ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showMoreOptions = true
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Theme.Colors.textPrimary)
                }
            }
        }
        .sheet(isPresented: $showMoreOptions) {
            if let song = nowPlayingManager.currentSong {
                MoreOptionsSheet(song: song) {
                    path.append(AppDestination.album(collectionId: song.collectionId))
                }
            }
        }
        .onDisappear {
            if !path.contains(.player) {
                nowPlayingManager.stop()
            }
        }
    }

    // MARK: - Artwork

    private var artwork: some View {
        ArtworkView(
            url: nowPlayingManager.currentSong?.artworkLargeURL,
            size: Theme.Sizing.playerArtwork,
            cornerRadius: Theme.Sizing.playerArtworkCornerRadius
        )
        .shadow(color: .black.opacity(0.5), radius: 20, y: 10)
    }

    // MARK: - Song Info

    private var songInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(nowPlayingManager.currentSong?.trackName ?? "")
                .font(Theme.Fonts.display(32))
                .foregroundStyle(Theme.Colors.textPrimary)
                .lineLimit(2)

            HStack {
                Text(nowPlayingManager.currentSong?.artistName ?? "")
                    .font(Theme.Fonts.text(16))
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .lineLimit(1)

                Spacer(minLength: 16)

                Button {
                    // Repeat toggle
                } label: {
                    Image(.Player.icRepeat)
                        .renderingMode(.template)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    // MARK: - Timeline

    private func timeline(audioPlayer: AudioPlayer) -> some View {
        VStack(spacing: 4) {
            Slider(
                value: Binding(
                    get: { isSeeking ? seekTime : audioPlayer.currentTime },
                    set: { newValue in
                        isSeeking = true
                        seekTime = newValue
                    }
                ),
                in: 0...max(audioPlayer.duration, 1),
                onEditingChanged: { editing in
                    if !editing {
                        nowPlayingManager.seek(to: seekTime)
                        isSeeking = false
                    }
                }
            )
            .tint(.white.opacity(0.6))
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white.opacity(0.25))
                    .frame(height: 8),
                alignment: .center
            )

            HStack {
                Text(formatTime(isSeeking ? seekTime : audioPlayer.currentTime))
                    .font(Theme.Fonts.mono(12))
                    .foregroundStyle(Theme.Colors.textTertiary)

                Spacer()

                Text(formatRemainingTime(
                    current: isSeeking ? seekTime : audioPlayer.currentTime,
                    duration: audioPlayer.duration
                ))
                .font(Theme.Fonts.mono(12))
                .foregroundStyle(Theme.Colors.textTertiary)
            }
        }
        .padding(.bottom, 24)
    }

    // MARK: - Playback Controls

    private func playbackControls(audioPlayer: AudioPlayer) -> some View {
        HStack(spacing: 28) {
            Button {
                nowPlayingManager.backward()
            } label: {
                Image(.Player.icBackwardBarFill)
                    .foregroundStyle(Theme.Colors.textPrimary)
            }
            .buttonStyle(.plain)

            Button {
                nowPlayingManager.togglePlayPause()
            } label: {
                Image(systemName: playPauseIcon(for: audioPlayer.playbackState))
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.Colors.textPrimary)
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
                    .glassEffect(.regular)
            }
            .buttonStyle(.plain)

            Button {
                nowPlayingManager.forward()
            } label: {
                Image(.Player.icForwardBarFill)
                    .foregroundStyle(Theme.Colors.textPrimary)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private func playPauseIcon(for state: PlaybackState) -> String {
        switch state {
        case .playing:
            "pause.fill"
        default:
            "play.fill"
        }
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        return Duration.seconds(seconds).formatted(
            .time(pattern: .minuteSecond(padMinuteToLength: 1))
        )
    }

    private func formatRemainingTime(current: TimeInterval, duration: TimeInterval) -> String {
        guard duration.isFinite, duration > 0 else { return "-0:00" }
        let remaining = max(duration - current, 0)
        return "-\(formatTime(remaining))"
    }
}

#Preview {
    NavigationStack {
        PlayerScreen(path: .constant([]))
    }
    .environment(PreviewHelpers.nowPlayingManagerWithSong())
    .modelContainer(PreviewHelpers.modelContainer)
    .preferredColorScheme(.dark)
}
