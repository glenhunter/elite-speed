import Testing
@testable import EliteSpeed

struct PortraitLayoutTests {

    @Test func everythingShownUsesTheDesignShares() {
        let s = PortraitLayout.shares(showMap: true, showRow: true, showMedia: true)
        #expect(s.speed == 0.25 && s.map == 0.50 && s.row == 0.12 && s.media == 0.13)
    }

    @Test func hiddenMapLeavesTheSpeedWhereItWas() {
        // The readout stays at the top at the same size; the map's space is simply empty.
        let s = PortraitLayout.shares(showMap: false, showRow: true, showMedia: true)
        #expect(s.speed == 0.25 && s.map == 0)
    }

    @Test func hiddenRowAndMediaLeaveTheSpeedWhereItWas() {
        let s = PortraitLayout.shares(showMap: true, showRow: false, showMedia: false)
        #expect(s.speed == 0.25 && s.row == 0 && s.media == 0)
    }

    @Test func everythingHiddenStillKeepsTheSpeedShare() {
        let s = PortraitLayout.shares(showMap: false, showRow: false, showMedia: false)
        #expect(s.speed == 0.25 && s.map == 0 && s.row == 0 && s.media == 0)
    }

    @Test func largerSpeedShareComesOutOfTheMap() {
        // Clock, compass and controls keep their quarter; the map gives up the difference.
        let s = PortraitLayout.shares(showMap: true, showRow: true, showMedia: true, speed: 0.48)
        #expect(s.speed == 0.48 && abs(s.map - 0.27) < 0.0001 && s.row == 0.12 && s.media == 0.13)
    }

    @Test func roundelPanelHeightIsTheCircleWithinTheSideMarginsPlusAGapBelow() {
        // 402 wide screen, 36 each side: circle 330, plus one gap below. The top sits on the
        // safe area, which already clears the Dynamic Island by about a gap.
        #expect(PortraitLayout.roundelPanelHeight(screenWidth: 402, sideMargin: 36, gap: 12) == 342)
    }
}
