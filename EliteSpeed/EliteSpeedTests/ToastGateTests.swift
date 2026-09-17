import Testing
@testable import EliteSpeed

struct ToastGateTests {

    @Test func firstObservedTrackDoesNotToast() {
        // Launching while a playlist is already playing must not announce the current track.
        #expect(!ToastGate.shouldShow(previous: nil, current: 1))
    }

    @Test func sameTrackDoesNotToast() {
        #expect(!ToastGate.shouldShow(previous: 1, current: 1))
    }

    @Test func differentTrackToasts() {
        #expect(ToastGate.shouldShow(previous: 1, current: 2))
    }

    @Test func playbackEndingDoesNotToast() {
        #expect(!ToastGate.shouldShow(previous: 1, current: nil))
    }
}
