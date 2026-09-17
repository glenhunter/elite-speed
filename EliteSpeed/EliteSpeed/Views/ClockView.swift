import SwiftUI

struct ClockView: View {
    var body: some View {
        TimelineView(.everyMinute) { context in
            Text(context.date, style: .time)
                .font(.speedo(size: 56))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#Preview {
    ClockView()
}
