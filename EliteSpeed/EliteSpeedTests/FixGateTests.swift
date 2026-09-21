import Testing
@testable import EliteSpeed

struct FixGateTests {

    @Test func freshAccurateFixIsAccepted() {
        #expect(FixGate.accepts(age: 1, horizontalAccuracy: 10))
    }

    @Test func cachedFixFromMinutesAgoIsRejected() {
        // Core Location's first callback is often the last-known location from a previous drive.
        #expect(!FixGate.accepts(age: 120, horizontalAccuracy: 10))
    }

    @Test func fixWithUnknownAccuracyIsRejected() {
        #expect(!FixGate.accepts(age: 1, horizontalAccuracy: -1))
    }

    @Test func fixWithVeryPoorAccuracyIsRejected() {
        // A cell-tower fix hundreds of metres out is no use for a speedometer.
        #expect(!FixGate.accepts(age: 1, horizontalAccuracy: 500))
    }

    @Test func fixAtTheAgeLimitIsAccepted() {
        #expect(FixGate.accepts(age: FixGate.maximumAge, horizontalAccuracy: 10))
    }
}
