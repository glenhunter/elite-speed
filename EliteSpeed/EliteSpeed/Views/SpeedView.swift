import SwiftUI

struct SpeedView: View {
    @Environment(SpeedModel.self) private var speed
    @AppStorage(Settings.units) private var units = SpeedUnit.kmh

    private var reading: SpeedReading? { speed.reading }

    private var digits: String {
        reading?.displayValue(in: units).map(String.init) ?? "--"
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(digits)
                .font(.speedo(.medium, size: 220))
                .monospacedDigit()
                .tracking(-4)
                .minimumScaleFactor(0.3)
                .lineLimit(1)
                .opacity(reading?.isAccuracyPoor ?? true ? 0.4 : 1)
            Text(units.label)
                .font(.speedo(size: 32))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Speed")
        .accessibilityValue(reading?.displayValue(in: units).map { "\($0) \(units.label)" } ?? "no reading")
    }
}

#Preview {
    SpeedView()
        .environment(SpeedModel())
}
