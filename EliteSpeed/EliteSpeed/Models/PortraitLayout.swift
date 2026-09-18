import Foundation

/// Share of the portrait height each panel gets. The speed keeps its share whatever is hidden,
/// so the readout never moves or resizes; hidden panels simply leave empty space.
nonisolated enum PortraitLayout {
    struct Shares: Equatable {
        let speed: Double
        let map: Double
        let row: Double
        let media: Double
    }

    /// Clock and compass row (7%) plus controls (13%), always reserved.
    private static let lowerShare = 0.20

    /// `speed` defaults to the design's quarter; a roundel asks for more and the map yields it.
    static func shares(showMap: Bool, showRow: Bool, showMedia: Bool, speed: Double = 0.25) -> Shares {
        Shares(speed: speed,
               map: showMap ? 1 - speed - lowerShare : 0,
               row: showRow ? 0.07 : 0,
               media: showMedia ? 0.13 : 0)
    }

    /// Height the speed panel needs for a roundel inset `sideMargin` from each screen edge, with
    /// a gap below. Nothing above: the safe area already clears the Dynamic Island by about a gap.
    static func roundelPanelHeight(screenWidth: Double, sideMargin: Double, gap: Double) -> Double {
        let diameter = screenWidth - 2 * sideMargin
        return diameter + gap
    }
}
