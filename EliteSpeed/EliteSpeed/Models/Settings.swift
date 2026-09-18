import SwiftUI

/// `@AppStorage` keys. Views read them directly, e.g. `@AppStorage(Settings.showMap) var showMap = true`.
enum Settings {
    static let units = "units"
    static let digitColour = "digitColour"
    static let nightMode = "nightMode"
    static let showMap = "showMap"
    static let mapFollowsHeading = "mapFollowsHeading"
    static let showClock = "showClock"
    static let clockFormat = "clockFormat"
    static let showCompass = "showCompass"
    static let showMediaControls = "showMediaControls"
}

enum SpeedUnit: String, CaseIterable {
    case kmh
    case mph

    var label: String {
        switch self {
        case .kmh: "km/h"
        case .mph: "mph"
        }
    }
}

/// Dashboard foreground presets, all chosen to read on black.
enum DigitColour: String, CaseIterable {
    case white
    case amber
    case green
    case cyan
    case red

    var color: Color {
        switch self {
        case .white: .white
        case .amber: Color(red: 1.0, green: 0.70, blue: 0.10)
        case .green: Color(red: 0.30, green: 0.90, blue: 0.40)
        case .cyan: Color(red: 0.30, green: 0.85, blue: 1.0)
        case .red: Color(red: 1.0, green: 0.25, blue: 0.20)
        }
    }

    var label: String { rawValue.capitalized }

    /// Deeper red than the preset, for preserving night vision.
    static let night = Color(red: 0.95, green: 0.15, blue: 0.10)
}
