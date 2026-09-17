import Foundation

/// Decides whether a now-playing change deserves a toast.
nonisolated enum ToastGate {
    /// True only when a known track changed to a different known track. Launching mid-playlist,
    /// repeats of the same item and playback ending stay silent.
    static func shouldShow(previous: UInt64?, current: UInt64?) -> Bool {
        guard let previous, let current else { return false }
        return previous != current
    }
}
