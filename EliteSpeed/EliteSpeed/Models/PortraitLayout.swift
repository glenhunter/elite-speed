import Foundation

/// Share of the portrait height each panel gets. Hidden panels give their share to the speed.
nonisolated enum PortraitLayout {
    struct Shares: Equatable {
        let speed: Double
        let map: Double
        let row: Double
        let media: Double
    }

    static func shares(showMap: Bool, showRow: Bool, showMedia: Bool) -> Shares {
        // Integer percentages so the sums stay exact.
        var speed = 25
        let map = showMap ? 50 : 0
        let row = showRow ? 12 : 0
        let media = showMedia ? 13 : 0
        speed = 100 - map - row - media
        return Shares(speed: Double(speed) / 100, map: Double(map) / 100,
                      row: Double(row) / 100, media: Double(media) / 100)
    }
}
