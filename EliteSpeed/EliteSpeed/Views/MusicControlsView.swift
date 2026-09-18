import SwiftUI

struct MusicControlsView: View {
    @Environment(MusicModel.self) private var music
    /// Incremented on every tap so the haptic fires each time, eyes on the road.
    @State private var tapCount = 0

    var body: some View {
        HStack(spacing: 12) {
            control("backward.fill", label: "Previous track") { music.previous() }
            control(music.isPlaying ? "pause.fill" : "play.fill",
                    label: music.isPlaying ? "Pause" : "Play") { music.togglePlayPause() }
            control("forward.fill", label: "Next track") { music.next() }
        }
        .symbolRenderingMode(.hierarchical)
        .sensoryFeedback(.impact(weight: .light), trigger: tapCount)
    }

    private func control(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            tapCount += 1
            action()
        } label: {
            Image(systemName: symbol)
                // Medium weight sits at a similar visual weight to Barlow.
                .font(.system(size: 36, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(minWidth: 60, minHeight: 60)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.tertiary, lineWidth: 1))
        .accessibilityLabel(label)
    }
}

#Preview {
    MusicControlsView()
        .environment(MusicModel())
}
