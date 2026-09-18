import SwiftUI

struct ClockView: View {
    @AppStorage(Settings.clockFormat) private var format = ClockFormat.system

    var body: some View {
        TimelineView(.everyMinute) { context in
            Text(format.string(for: context.date))
                .font(.speedo(size: 56))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    ClockView()
}
