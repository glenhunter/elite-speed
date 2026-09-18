import Foundation
import Testing
@testable import EliteSpeed

struct ClockFormatTests {
    static let evening: Date = {
        var c = DateComponents(); c.year = 2025; c.month = 9; c.day = 18; c.hour = 21; c.minute = 5
        var cal = Calendar(identifier: .gregorian); cal.timeZone = TimeZone(identifier: "UTC")!
        return cal.date(from: c)!
    }()
    static let utc = TimeZone(identifier: "UTC")!

    /// Normalises the narrow no-break space iOS puts before AM/PM and lowercases the meridiem.
    static func plain(_ s: String) -> String {
        s.replacingOccurrences(of: "\u{202F}", with: " ").replacingOccurrences(of: "\u{00A0}", with: " ").lowercased()
    }

    @Test func twentyFourHourIgnoresLocale() {
        #expect(ClockFormat.twentyFourHour.string(for: Self.evening, locale: Locale(identifier: "en_US"), timeZone: Self.utc) == "21:05")
    }

    @Test func twelveHourIgnoresLocale() {
        #expect(Self.plain(ClockFormat.twelveHour.string(for: Self.evening, locale: Locale(identifier: "en_GB"), timeZone: Self.utc)) == "9:05 pm")
    }

    @Test func systemFollowsLocale() {
        #expect(ClockFormat.system.string(for: Self.evening, locale: Locale(identifier: "en_GB"), timeZone: Self.utc) == "21:05")
        #expect(Self.plain(ClockFormat.system.string(for: Self.evening, locale: Locale(identifier: "en_US"), timeZone: Self.utc)) == "9:05 pm")
    }
}
