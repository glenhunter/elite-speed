import Foundation

/// Landscape widths. The column is as wide as its stacked buttons or the clock need; the speed
/// takes what a full-height roundel needs, or 35:40 with the map for bare digits; the map gets
/// the rest. Hidden panels give their width to the speed.
nonisolated enum LandscapeLayout {
    struct Widths: Equatable {
        let column: Double
        let speed: Double
        let map: Double
    }

    /// Narrowest useful map: enough to see the next junction.
    static let minimumMapWidth: Double = 150

    /// Width a centred roundel needs when it fills the panel height: the circle plus its side insets.
    static func roundelPanelWidth(panelHeight: Double, gap: Double, sideInset: Double) -> Double {
        (panelHeight - 2 * gap) + 2 * sideInset
    }

    /// Stacked buttons above the clock: the wider of the two, plus padding either side.
    static func columnWidth(buttonSize: Double, clockWidth: Double, padding: Double) -> Double {
        max(buttonSize, clockWidth) + 2 * padding
    }

    /// `speedNatural` is the width a full-height roundel wants; nil means bare digits.
    static func widths(total: Double, column: Double, speedNatural: Double?, showColumn: Bool, showMap: Bool) -> Widths {
        let columnWidth = showColumn ? column : 0
        let remainder = total - columnWidth
        guard showMap else {
            return Widths(column: columnWidth, speed: remainder, map: 0)
        }
        let speed: Double
        if let speedNatural {
            speed = min(speedNatural, remainder - minimumMapWidth)
        } else {
            speed = remainder * 35 / 75
        }
        return Widths(column: columnWidth, speed: speed, map: remainder - speed)
    }
}
