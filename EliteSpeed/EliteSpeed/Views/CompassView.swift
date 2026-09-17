import SwiftUI

/// Fixed north-up dial with a needle showing direction of travel from GPS course.
/// Dimmed while stopped, when the needle holds the last course driven.
struct CompassView: View {
    @Environment(SpeedModel.self) private var speed
    /// Accumulates the shortest signed delta each update, so 358° → 2° turns 4° rather than 356°.
    @State private var displayedAngle = 0.0

    private var heading: Double? { speed.heading }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                let radius = min(geometry.size.width, geometry.size.height) / 2
                ZStack {
                    dial(radius: radius)
                    Image(systemName: "location.north.fill")
                        .font(.system(size: radius * 0.9, weight: .medium))
                        .rotationEffect(.degrees(displayedAngle))
                }
                .frame(width: radius * 2, height: radius * 2)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
            Text(heading.map(Heading.cardinal) ?? "--")
                .font(.speedo(.semiBold, size: 32))
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(speed.isHeadingLive ? 1 : 0.4)
        .onChange(of: heading, initial: true) { _, newHeading in
            guard let newHeading else { return }
            withAnimation(.easeInOut(duration: 0.3)) {
                displayedAngle += Heading.shortestDelta(from: displayedAngle, to: newHeading)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Heading")
        .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: String {
        guard let heading else { return "unknown" }
        let value = "\(Heading.cardinal(heading)), \(Int(heading.rounded())) degrees"
        return speed.isHeadingLive ? value : value + ", held while stopped"
    }

    private func dial(radius: CGFloat) -> some View {
        ZStack {
            Circle().strokeBorder(.secondary, lineWidth: 2)
            ForEach(Array(["N", "E", "S", "W"].enumerated()), id: \.offset) { index, point in
                let angle = Double(index) * 90
                Text(point)
                    .font(.speedo(.medium, size: radius * 0.28))
                    .rotationEffect(.degrees(-angle))   // keep the letter upright
                    .offset(y: -radius * 0.76)
                    .rotationEffect(.degrees(angle))    // move it round the dial
            }
        }
    }
}

#Preview {
    CompassView()
        .environment(SpeedModel())
}
