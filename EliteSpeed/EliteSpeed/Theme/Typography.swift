import SwiftUI

/// Every view goes through here so a missing font shows up in one place, not as a silent system-font fallback.
extension Font {
    enum SpeedoWeight: String {
        case regular = "BarlowSemiCondensed-Regular"
        case medium = "BarlowSemiCondensed-Medium"
        case semiBold = "BarlowSemiCondensed-SemiBold"
    }

    static func speedo(_ weight: SpeedoWeight = .regular, size: CGFloat) -> Font {
        .custom(weight.rawValue, size: size)
    }
}
