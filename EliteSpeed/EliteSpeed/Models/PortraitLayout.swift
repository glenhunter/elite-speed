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

    /// Bare digits take the design's quarter; a roundel asks for more and the map yields it.
    static let defaultSpeedShare = 0.25
    private static let rowShare = 0.07
    private static let mediaShare = 0.13
    /// Clock and compass row plus controls, always reserved whether shown or not.
    private static var lowerShare: Double { rowShare + mediaShare }

    static func shares(showMap: Bool, showRow: Bool, showMedia: Bool, speed: Double = defaultSpeedShare) -> Shares {
        Shares(speed: speed,
               map: showMap ? max(0, 1 - speed - lowerShare) : 0,
               row: showRow ? rowShare : 0,
               media: showMedia ? mediaShare : 0)
    }

    /// Height the speed panel needs for a roundel inset `sideMargin` from each screen edge, with
    /// a gap below. Nothing above: the safe area already clears the Dynamic Island by about a gap.
    static func roundelPanelHeight(screenWidth: Double, sideMargin: Double, gap: Double) -> Double {
        let diameter = screenWidth - 2 * sideMargin
        return diameter + gap
    }
}
