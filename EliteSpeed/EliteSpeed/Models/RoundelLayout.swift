import Foundation

/// Sizes the speed digits to fit inside a door-number circle together with the unit label.
nonisolated enum RoundelLayout {
    struct Metrics {
        /// Digit cap height in ems.
        let capRatio: Double
        /// Width of one tabular digit in ems.
        let digitWidthRatio: Double
        /// Visible height of the unit label under the digits, in points.
        let unitInkHeight: Double
        /// Space between digits and unit label, in points.
        let gap: Double
    }

    /// Largest font size whose block of `digits` digits plus the unit label fits the circle.
    /// The block is a rectangle of width `digits × digitWidth × size` and height
    /// `cap × size + gap + unitInk`; its corners must lie within the radius.
    static func digitSize(diameter: Double, digits: Int, metrics m: Metrics) -> Double {
        let radius = diameter / 2
        let widthPerEm = Double(digits) * m.digitWidthRatio
        let fixedHeight = m.gap + m.unitInkHeight
        // (widthPerEm·s)² + (cap·s + fixed)² = (2r)²  →  a·s² + b·s + c = 0
        let a = widthPerEm * widthPerEm + m.capRatio * m.capRatio
        let b = 2 * m.capRatio * fixedHeight
        let c = fixedHeight * fixedHeight - 4 * radius * radius
        let discriminant = b * b - 4 * a * c
        guard discriminant > 0 else { return 0 }
        return max(0, (-b + discriminant.squareRoot()) / (2 * a))
    }
}
