import CoreText
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

    /// Typographic width of `text` in the Barlow weight and size, for laying out around it.
    static func speedoWidth(of text: String, weight: SpeedoWeight = .regular, size: CGFloat) -> CGFloat {
        guard let font = UIFont(name: weight.rawValue, size: size) else { return 0 }
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: [.font: font]))
        return CTLineGetTypographicBounds(line, nil, nil, nil)
    }
}
