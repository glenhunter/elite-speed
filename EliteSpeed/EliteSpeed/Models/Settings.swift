import Foundation

/// `@AppStorage` keys. Views read them directly, e.g. `@AppStorage(Settings.showMap) var showMap = true`.
enum Settings {
    static let showMap = "showMap"
    static let mapFollowsHeading = "mapFollowsHeading"
    static let units = "units"
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
