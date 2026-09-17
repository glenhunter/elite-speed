import SwiftUI

/// One-point separator line in the tertiary foreground colour.
struct Keyline: View {
    let axis: Axis

    var body: some View {
        Rectangle()
            .fill(.tertiary)
            .frame(width: axis == .vertical ? 1 : nil, height: axis == .horizontal ? 1 : nil)
            .accessibilityHidden(true)
    }
}
