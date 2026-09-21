import SwiftUI

/// Slides down from the top for a few seconds when the track changes.
struct NowPlayingToast: View {
    @Environment(MusicModel.self) private var music

    var body: some View {
        ZStack {
            if let track = music.toast {
                content(for: track)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.4), value: music.toast)
    }

    private func content(for track: TrackInfo) -> some View {
        HStack(spacing: 12) {
            if let artwork = track.artwork {
                Image(uiImage: artwork)
                    .resizable()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: 28))
                    .frame(width: 56, height: 56)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.speedo(.semiBold, size: 24))
                if let artist = track.artist {
                    Text(artist)
                        .font(.speedo(size: 20))
                        .foregroundStyle(.secondary)
                }
            }
            .lineLimit(1)
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.top, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Now playing")
        .accessibilityValue([track.title, track.artist].compactMap { $0 }.joined(separator: ", "))
        // No accessibility action: it is a transient announcement, not a control.
    }
}

#Preview {
    NowPlayingToast()
        .environment(MusicModel())
}
