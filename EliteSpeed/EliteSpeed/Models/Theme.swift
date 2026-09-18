import SwiftUI

/// Racing liveries as colour schemes. Classic is the plain black dashboard with a chosen digit colour.
nonisolated enum Theme: String, CaseIterable {
    case classic
    case teamLotus
    case blackAndGold
    case gulf
    case rothmans
    case rossoCorsa
    case alpine
    case motorsport

    var label: String {
        switch self {
        case .classic: "Classic"
        case .teamLotus: "Team Lotus"
        case .blackAndGold: "Black and Gold"
        case .gulf: "Gulf"
        case .rothmans: "Rothmans"
        case .rossoCorsa: "Rosso Corsa"
        case .alpine: "Alpine"
        case .motorsport: "Motorsport"
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
                           roundel: roundel, mapIsLight: true)
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
            return Palette(upperBackground: navy, lowerBackground: white,
                           upperForeground: white, lowerForeground: navy,
                           roundel: roundel, mapIsLight: true)
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
            return Palette(upperBackground: white, lowerBackground: white,
                           upperForeground: blue, lowerForeground: blue,
                           roundel: Palette.Roundel(fill: white, ring: blue, digits: black), mapIsLight: true)
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
