import SwiftUI

struct MusicControlsView: View {
    @Environment(MusicModel.self) private var music

    var body: some View {
        HStack(spacing: 24) {
            control("backward.fill", label: "Previous track") { music.previous() }
            control(music.isPlaying ? "pause.fill" : "play.fill",
                    label: music.isPlaying ? "Pause" : "Play") { music.togglePlayPause() }
            control("forward.fill", label: "Next track") { music.next() }
        }
        .symbolRenderingMode(.hierarchical)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func control(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                // Medium weight sits at a similar visual weight to Barlow.
                .font(.system(size: 36, weight: .medium))
                .frame(minWidth: 60, minHeight: 60)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    MusicControlsView()
        .environment(MusicModel())
}
