import SwiftUI

/// Racing liveries as colour schemes, shown under plain colour names. Classic is the plain black
/// dashboard with a chosen digit colour. The case names are stored in settings, so they stay put.
nonisolated enum Theme: String, CaseIterable {
    case classic
    case teamLotus
    case blackAndGold
    case gulf
    case rothmans
    case rossoCorsa
    case alpine
    case motorsport
    case martini

    var label: String {
        switch self {
        case .classic: "Classic"
        case .teamLotus: "Green & Yellow"
        case .blackAndGold: "Black and Gold"
        case .gulf: "Pale Blue"
        case .rothmans: "White"
        case .rossoCorsa: "Red"
        case .alpine: "Blue & White"
        case .motorsport: "Motorsport"
        case .martini: "Blue Stripes"
        }
    }

    /// The livery's own colours. Classic takes the digit colour from settings.
    func palette(digitColour: DigitColour) -> Palette {
        let white = Color.white
        let black = Color.black
        let roundel = Palette.Roundel(fill: white, ring: nil, digits: black)
        switch self {
        case .classic:
            return Palette(upperBackground: black, lowerBackground: black,
                           upperForeground: digitColour.color, lowerForeground: digitColour.color,
                           roundel: nil, mapIsLight: false)
        case .teamLotus:
            let green = Color(red: 0.00, green: 0.26, blue: 0.15)
            let yellow = Color(red: 1.00, green: 0.84, blue: 0.00)
            return Palette(upperBackground: green, lowerBackground: yellow,
                           upperForeground: yellow, lowerForeground: green,
                           roundel: roundel, mapIsLight: true,
                           stripes: Stripes.centred(width: 0.18, color: yellow, pinstripe: 0.015, pinstripeColor: white))
        case .blackAndGold:
            let gold = Color(red: 0.79, green: 0.64, blue: 0.15)
            return Palette(upperBackground: black, lowerBackground: black,
                           upperForeground: gold, lowerForeground: gold,
                           roundel: Palette.Roundel(fill: black, ring: gold, digits: gold), mapIsLight: true)
        case .gulf:
            let blue = Color(red: 0.49, green: 0.72, blue: 0.85)
            let orange = Color(red: 0.95, green: 0.55, blue: 0.16)
            let navy = Color(red: 0.04, green: 0.12, blue: 0.23)
            return Palette(upperBackground: blue, lowerBackground: orange,
                           upperForeground: navy, lowerForeground: white,
                           roundel: roundel, mapIsLight: true)
        case .rothmans:
            let navy = Color(red: 0.06, green: 0.17, blue: 0.35)
            let red = Color(red: 0.80, green: 0.10, blue: 0.16)
            let gold = Color(red: 0.85, green: 0.65, blue: 0.20)
            return Palette(upperBackground: navy, lowerBackground: white,
                           upperForeground: white, lowerForeground: navy,
                           roundel: roundel, mapIsLight: true,
                           stripes: Stripes(bands: [
                               Stripes.Band(start: 0.80, width: 0.035, color: red),
                               Stripes.Band(start: 0.835, width: 0.02, color: gold),
                           ]))
        case .rossoCorsa:
            let red = Color(red: 0.83, green: 0.00, blue: 0.00)
            return Palette(upperBackground: red, lowerBackground: black,
                           upperForeground: white, lowerForeground: white,
                           roundel: roundel, mapIsLight: true)
        case .alpine:
            let blue = Color(red: 0.17, green: 0.42, blue: 0.77)
            return Palette(upperBackground: blue, lowerBackground: white,
                           upperForeground: white, lowerForeground: blue,
                           roundel: roundel, mapIsLight: true)
        case .motorsport:
            let blue = Color(red: 0.11, green: 0.25, blue: 0.58)
            let lightBlue = Color(red: 0.00, green: 0.40, blue: 0.70)
            let violet = Color(red: 0.24, green: 0.13, blue: 0.50)
            let red = Color(red: 0.90, green: 0.13, blue: 0.18)
            return Palette(upperBackground: white, lowerBackground: white,
                           upperForeground: blue, lowerForeground: blue,
                           roundel: Palette.Roundel(fill: white, ring: blue, digits: black), mapIsLight: true,
                           stripes: Stripes(bands: [
                               Stripes.Band(start: 0.70, width: 0.045, color: lightBlue),
                               Stripes.Band(start: 0.745, width: 0.045, color: violet),
                               Stripes.Band(start: 0.79, width: 0.045, color: red),
                           ]))
        case .martini:
            let navy = Color(red: 0.05, green: 0.15, blue: 0.40)
            let lightBlue = Color(red: 0.45, green: 0.75, blue: 0.90)
            let red = Color(red: 0.85, green: 0.10, blue: 0.20)
            return Palette(upperBackground: white, lowerBackground: white,
                           upperForeground: navy, lowerForeground: navy,
                           roundel: Palette.Roundel(fill: white, ring: navy, digits: black), mapIsLight: true,
                           stripes: Stripes(bands: [
                               Stripes.Band(start: 0.20, width: 0.03, color: lightBlue),
                               Stripes.Band(start: 0.245, width: 0.09, color: navy),
                               Stripes.Band(start: 0.35, width: 0.03, color: red),
                           ]))
        }
    }
}

/// The colours the dashboard draws with, after theme, swatch and night mode are settled.
nonisolated struct Palette: Equatable {
    struct Roundel: Equatable {
        let fill: Color
        let ring: Color?
        let digits: Color
    }

    /// Under the speed and map.
    let upperBackground: Color
    /// Under the clock, compass and controls.
    let lowerBackground: Color
    let upperForeground: Color
    let lowerForeground: Color
    /// Present on liveries: the speed sits in a door-number circle.
    let roundel: Roundel?
    /// Liveries use the light map by day so it reads against any colour; Classic and night keep the dark one.
    let mapIsLight: Bool
    /// Racing stripes across the upper zone, behind the speed and map.
    var stripes: Stripes? = nil

    /// Night safe colours: red on black, no roundel, whatever the theme.
    static let night = Palette(upperBackground: .black, lowerBackground: .black,
                               upperForeground: DigitColour.night, lowerForeground: DigitColour.night,
                               roundel: nil, mapIsLight: false)

    static func resolve(theme: Theme, digitColour: DigitColour, night: Bool) -> Palette {
        night ? .night : theme.palette(digitColour: digitColour)
    }
}

private struct PaletteKey: EnvironmentKey {
    static let defaultValue = Palette.resolve(theme: .classic, digitColour: .white, night: false)
}

extension EnvironmentValues {
    var palette: Palette {
        get { self[PaletteKey.self] }
        set { self[PaletteKey.self] = newValue }
    }
}
