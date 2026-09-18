import SwiftUI

/// Direction of travel from GPS course as a cardinal label.
/// Dimmed while stopped, when it holds the last course driven.
struct CompassView: View {
    @Environment(SpeedModel.self) private var speed

    private var heading: Double? { speed.heading }

    var body: some View {
        Text(heading.map(Heading.cardinal) ?? "--")
            .font(.speedo(.semiBold, size: 28))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(speed.isHeadingLive ? 1 : 0.6)
            .accessibilityLabel("Heading")
            .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: String {
        guard let heading else { return "unknown" }
        let value = "\(Heading.cardinal(heading)), \(Int(heading.rounded())) degrees"
        return speed.isHeadingLive ? value : value + ", held while stopped"
    }
}

#Preview {
    CompassView()
        .environment(SpeedModel())
}
