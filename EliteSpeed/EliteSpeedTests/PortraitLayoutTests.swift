import Testing
@testable import EliteSpeed

struct PortraitLayoutTests {

    @Test func everythingShownUsesTheDesignShares() {
        let s = PortraitLayout.shares(showMap: true, showRow: true, showMedia: true)
        #expect(s.speed == 0.25 && s.map == 0.50 && s.row == 0.12 && s.media == 0.13)
    }

    @Test func hiddenMapGivesItsShareToTheSpeed() {
        let s = PortraitLayout.shares(showMap: false, showRow: true, showMedia: true)
        #expect(s.speed == 0.75 && s.map == 0)
    }

    @Test func hiddenRowAndMediaGiveTheirSharesToTheSpeed() {
        let s = PortraitLayout.shares(showMap: true, showRow: false, showMedia: false)
        #expect(s.speed == 0.50 && s.row == 0 && s.media == 0)
    }

    @Test func everythingHiddenLeavesOnlyTheSpeed() {
        let s = PortraitLayout.shares(showMap: false, showRow: false, showMedia: false)
        #expect(s.speed == 1 && s.map == 0 && s.row == 0 && s.media == 0)
    }
}
