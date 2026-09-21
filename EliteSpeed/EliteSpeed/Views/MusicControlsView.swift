import SwiftUI

struct MusicControlsView: View {
    /// Fixed button size, or nil to fill the available space.
    var buttonSize: CGSize? = nil
    /// Buttons side by side, or stacked for a narrow column.
    var axis: Axis = .horizontal

    @Environment(MusicModel.self) private var music
    /// Incremented on every tap so the haptic fires each time, eyes on the road.
    @State private var tapCount = 0

    static let spacing: CGFloat = 8

    var body: some View {
        let layout = axis == .horizontal ? AnyLayout(HStackLayout(spacing: Self.spacing)) : AnyLayout(VStackLayout(spacing: Self.spacing))
        layout {
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
                .frame(width: buttonSize?.width, height: buttonSize?.height)
                .frame(maxWidth: buttonSize == nil ? .infinity : nil, maxHeight: buttonSize == nil ? .infinity : nil)
                .frame(minWidth: 44, minHeight: 44)
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
