import CoreText
import SwiftUI

struct SpeedView: View {
    /// Where the readout sits in its panel: bottom in portrait so it hugs the map, centre in landscape.
    var alignment: Alignment = .center
    /// Space between the panel's sides and the roundel.
    var roundelSideInset: CGFloat = 2 * Layout.gap

    @Environment(SpeedModel.self) private var speed
    @Environment(\.palette) private var palette
    @AppStorage(Settings.units) private var units = SpeedUnit.kmh

    private static let unitSize: CGFloat = 32
    private static let roundelUnitSize: CGFloat = 24
    private static let digitTracking: CGFloat = -4
    private static let unitFont = UIFont(name: Font.SpeedoWeight.regular.rawValue, size: unitSize)
    private static let roundelUnitFont = UIFont(name: Font.SpeedoWeight.regular.rawValue, size: roundelUnitSize)
    /// Metrics at 100pt give the ratios used to size the digits.
    private static let digitMetrics = UIFont(name: Font.SpeedoWeight.medium.rawValue, size: 100)
    /// Width of one tabular digit in ems.
    private static let digitWidthRatio: CGFloat = 0.507

    private var reading: SpeedReading? { speed.reading }

    private var digits: String {
        reading?.displayValue(in: units).map(String.init) ?? "--"
    }

    var body: some View {
        Group {
            if let roundel = palette.roundel {
                roundelReadout(roundel)
            } else {
                bareReadout
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Speed")
        .accessibilityValue(reading?.displayValue(in: units).map { "\($0) \(units.label)" } ?? "no reading")
    }

    // MARK: Bare digits (Classic and night)

    private var bareReadout: some View {
        GeometryReader { geometry in
            let unitInk = Self.inkBounds(of: units.label, font: Self.unitFont)
            let digitSize = Self.digitSize(fitting: geometry.size, unitInk: unitInk)
            VStack(spacing: Self.digitToUnitSpacing(digitSize: digitSize, unitInk: unitInk, unitFont: Self.unitFont)) {
                digitText(size: digitSize)
                Text(units.label)
                    .font(.speedo(size: Self.unitSize))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, alignment == .bottom ? Self.unitBottomPadding(unitInk: unitInk) : 0)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: alignment)
        }
    }

    // MARK: Roundel (liveries)

    /// A door-number circle inset from the panel's sides, digits and unit inside. Sized for two
    /// digits; three-digit speeds scale down to fit. Bottom-aligned it sits flush with the top of
    /// its panel and a gap above what follows; centred it keeps a gap above and below.
    private func roundelReadout(_ roundel: Palette.Roundel) -> some View {
        GeometryReader { geometry in
            let verticalRoom = geometry.size.height - (alignment == .bottom ? 1 : 2) * Layout.gap
            let diameter = min(geometry.size.width - 2 * roundelSideInset, verticalRoom)
            let unitInk = Self.inkBounds(of: units.label, font: Self.roundelUnitFont)
            let digitSize = Self.roundelDigitSize(diameter: diameter, unitInkHeight: unitInk.height)
            ZStack {
                Circle().fill(roundel.fill)
                if let ring = roundel.ring {
                    Circle().strokeBorder(ring, lineWidth: max(2, diameter * 0.02))
                }
                VStack(spacing: Self.digitToUnitSpacing(digitSize: digitSize, unitInk: unitInk, unitFont: Self.roundelUnitFont)) {
                    digitText(size: digitSize)
                        .minimumScaleFactor(0.6)
                    Text(units.label)
                        .font(.speedo(size: Self.roundelUnitSize))
                        .opacity(0.7)
                }
                .foregroundStyle(roundel.digits)
                // Centre the visible block, not the text frames, in the circle.
                .offset(y: Self.roundelBlockOffset(digitSize: digitSize, unitInk: unitInk))
            }
            .frame(width: diameter, height: diameter)
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: alignment == .bottom ? .bottom : .center)
            .padding(.bottom, alignment == .bottom ? Layout.gap : 0)
        }
    }

    private func digitText(size: CGFloat) -> some View {
        Text(digits)
            .font(.speedo(.medium, size: size))
            .monospacedDigit()
            .tracking(Self.digitTracking)
            .lineLimit(1)
            .opacity(reading?.isAccuracyPoor ?? true ? 0.6 : 1)
    }

    // MARK: Sizing

    // Text frames extend beyond the visible glyphs: below the baseline by the font's descent and
    // above by its ascent. The sums below work in visible ink so every gap the eye sees is `Layout.gap`.

    private static func inkBounds(of text: String, font: UIFont?) -> CGRect {
        guard let font else { return CGRect(x: 0, y: 0, width: 0, height: unitSize * 0.7) }
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

    private static func roundelDigitSize(diameter: CGFloat, unitInkHeight: CGFloat) -> CGFloat {
        guard let digitMetrics else { return 60 }
        let metrics = RoundelLayout.Metrics(capRatio: digitMetrics.capHeight / 100,
                                            digitWidthRatio: digitWidthRatio,
                                            unitInkHeight: unitInkHeight,
                                            gap: Layout.gap)
        return max(20, RoundelLayout.digitSize(diameter: diameter, digits: 2, metrics: metrics))
    }

    private static func digitToUnitSpacing(digitSize: CGFloat, unitInk: CGRect, unitFont: UIFont?) -> CGFloat {
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

    /// The text block's frames are taller than its ink, mostly above the digits. Shift so the
    /// ink, not the frames, is centred in the circle.
    private static func roundelBlockOffset(digitSize: CGFloat, unitInk: CGRect) -> CGFloat {
        guard let digitMetrics, let unitFont = roundelUnitFont else { return 0 }
        let spaceAboveDigitInk = (digitMetrics.ascender - digitMetrics.capHeight) / 100 * digitSize
        let spaceBelowUnitInk = -unitFont.descender + unitInk.minY
        // The ink's centre is below the frames' centre by half the difference; shift up to compensate.
        return -(spaceAboveDigitInk - spaceBelowUnitInk) / 2
    }
}

#Preview {
    SpeedView()
        .environment(SpeedModel())
}
