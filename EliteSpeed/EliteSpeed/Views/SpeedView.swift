import CoreText
import SwiftUI

struct SpeedView: View {
    /// Where the readout sits in its panel: bottom in portrait so it hugs the map, centre in landscape.
    var alignment: Alignment = .center

    @Environment(SpeedModel.self) private var speed
    @AppStorage(Settings.units) private var units = SpeedUnit.kmh

    private static let unitSize: CGFloat = 32
    private static let digitTracking: CGFloat = -4
    private static let unitFont = UIFont(name: Font.SpeedoWeight.regular.rawValue, size: unitSize)
    /// Metrics at 100pt give the ratios used to size the digits.
    private static let digitMetrics = UIFont(name: Font.SpeedoWeight.medium.rawValue, size: 100)
    /// Width of one tabular digit in ems.
    private static let digitWidthRatio: CGFloat = 0.507

    private var reading: SpeedReading? { speed.reading }

    private var digits: String {
        reading?.displayValue(in: units).map(String.init) ?? "--"
    }

    var body: some View {
        GeometryReader { geometry in
            let unitInk = Self.inkBounds(of: units.label)
            let digitSize = Self.digitSize(fitting: geometry.size, unitInk: unitInk)
            VStack(spacing: Self.digitToUnitSpacing(digitSize: digitSize, unitInk: unitInk)) {
                Text(digits)
                    .font(.speedo(.medium, size: digitSize))
                    .monospacedDigit()
                    .tracking(Self.digitTracking)
                    .lineLimit(1)
                    .opacity(reading?.isAccuracyPoor ?? true ? 0.6 : 1)
                Text(units.label)
                    .font(.speedo(size: Self.unitSize))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, alignment == .bottom ? Self.unitBottomPadding(unitInk: unitInk) : 0)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: alignment)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Speed")
        .accessibilityValue(reading?.displayValue(in: units).map { "\($0) \(units.label)" } ?? "no reading")
    }

    // Text frames extend beyond the visible glyphs: below the baseline by the font's descent and
    // above by its ascent. The sums below work in visible ink so every gap the eye sees is `Layout.gap`.

    /// Ink bounds of the unit label relative to its baseline: maxY is the top of "k" or "h",
    /// minY is negative when there is a descender, as in "mph".
    private static func inkBounds(of text: String) -> CGRect {
        guard let unitFont else { return CGRect(x: 0, y: 0, width: 0, height: unitSize * 0.7) }
        return inkBounds(of: text, font: unitFont)
    }

    private static func inkBounds(of text: String, font: UIFont) -> CGRect {
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font]))
        return CTLineGetBoundsWithOptions(line, [.useGlyphPathBounds])
    }

    /// How far a round digit dips below the baseline, in ems. Measured on "0" so the label
    /// sits still whether the reading has round or flat-bottomed digits.
    private static let digitOvershootRatio: CGFloat = {
        guard let digitMetrics else { return 0 }
        return max(0, -inkBounds(of: "0", font: digitMetrics).minY / 100)
    }()

    /// Largest digit size whose glyphs fit the panel with a gap above, a gap to the unit label,
    /// a gap below the label, and three digits across the width.
    private static func digitSize(fitting panel: CGSize, unitInk: CGRect) -> CGFloat {
        guard let digitMetrics else { return 100 }
        let capRatio = digitMetrics.capHeight / 100
        let capHeightAvailable = panel.height - 3 * Layout.gap - unitInk.height
        let byHeight = capHeightAvailable / capRatio
        let byWidth = (panel.width - 2 * digitTracking) / (3 * digitWidthRatio)
        return max(40, min(byHeight, byWidth))
    }

    private static func digitToUnitSpacing(digitSize: CGFloat, unitInk: CGRect) -> CGFloat {
        guard let unitFont, let digitMetrics else { return Layout.gap }
        let digitSpaceBelowInk = (-digitMetrics.descender / 100 - digitOvershootRatio) * digitSize
        let unitSpaceAboveInk = unitFont.ascender - unitInk.maxY
        return Layout.gap - digitSpaceBelowInk - unitSpaceAboveInk
    }

    private static func unitBottomPadding(unitInk: CGRect) -> CGFloat {
        guard let unitFont else { return Layout.gap }
        let unitSpaceBelowInk = -unitFont.descender + unitInk.minY
        return Layout.gap - unitSpaceBelowInk
    }
}

#Preview {
    SpeedView()
        .environment(SpeedModel())
}
