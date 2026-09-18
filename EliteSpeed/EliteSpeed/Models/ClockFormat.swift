import Foundation

nonisolated enum ClockFormat: String, CaseIterable {
    case system
    case twelveHour
    case twentyFourHour

    var label: String {
        switch self {
        case .system: "System"
        case .twelveHour: "12-hour"
        case .twentyFourHour: "24-hour"
        }
    }

    func string(for date: Date, locale: Locale = .current, timeZone: TimeZone = .current) -> String {
        date.formatted(Date.FormatStyle(date: .omitted, time: .shortened, locale: overriddenLocale(from: locale), timeZone: timeZone))
    }

    /// The hour cycle lives in the locale, not the format fields, so overriding means rebuilding the locale.
    private func overriddenLocale(from locale: Locale) -> Locale {
        var components = Locale.Components(locale: locale)
        switch self {
        case .system: return locale
        case .twelveHour: components.hourCycle = .oneToTwelve
        case .twentyFourHour: components.hourCycle = .zeroToTwentyThree
        }
        return Locale(components: components)
    }
}
