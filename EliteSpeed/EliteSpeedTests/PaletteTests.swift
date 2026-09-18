import SwiftUI
import Testing
@testable import EliteSpeed

struct PaletteTests {

    @Test func classicUsesTheSwatchOnBlackWithNoRoundel() {
        let p = Palette.resolve(theme: .classic, digitColour: .amber, night: false)
        #expect(p.upperBackground == .black && p.lowerBackground == .black)
        #expect(p.upperForeground == DigitColour.amber.color && p.lowerForeground == DigitColour.amber.color)
        #expect(p.roundel == nil)
    }

    @Test func liveryHasARoundelAndIgnoresTheSwatch() {
        let p = Palette.resolve(theme: .teamLotus, digitColour: .amber, night: false)
        #expect(p.roundel != nil)
        #expect(p.upperForeground != DigitColour.amber.color)
    }

    @Test func liveryZonesDiffer() {
        let p = Palette.resolve(theme: .teamLotus, digitColour: .white, night: false)
        #expect(p.upperBackground != p.lowerBackground)
    }

    @Test func nightOverridesEveryTheme() {
        for theme in Theme.allCases {
            let p = Palette.resolve(theme: theme, digitColour: .white, night: true)
            #expect(p == Palette.night, "\(theme)")
        }
    }

    @Test func nightIsRedOnBlackWithoutRoundel() {
        let p = Palette.night
        #expect(p.upperBackground == .black && p.lowerBackground == .black)
        #expect(p.upperForeground == DigitColour.night && p.lowerForeground == DigitColour.night)
        #expect(p.roundel == nil && p.mapIsLight == false)
    }
}
