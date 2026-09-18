import Foundation

/// Share of the landscape width each panel gets. Hidden panels give their share to the speed.
nonisolated enum LandscapeLayout {
    struct Shares: Equatable {
        let column: Double
        let speed: Double
        let map: Double
    }

    static func shares(showColumn: Bool, showMap: Bool) -> Shares {
        // Integer percentages so the sums stay exact.
        let column = showColumn ? 25 : 0
        let map = showMap ? 40 : 0
        let speed = 100 - column - map
        return Shares(column: Double(column) / 100, speed: Double(speed) / 100, map: Double(map) / 100)
    }
}
