import SwiftUI

struct ClockView: View {
    static let fontSize: CGFloat = 28

    @AppStorage(Settings.clockFormat) private var format = ClockFormat.system

    var body: some View {
        TimelineView(.everyMinute) { context in
            Text(format.string(for: context.date))
                .font(.speedo(size: Self.fontSize))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("Time")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    ClockView()
}
