import Testing
@testable import EliteSpeed

struct HeadingTests {

    // MARK: Course from GPS

    @Test func negativeCourseIsInvalid() {
        #expect(Heading.validCourse(-1, accuracy: 5) == nil)
    }

    @Test func courseWithPoorAccuracyIsInvalid() {
        #expect(Heading.validCourse(90, accuracy: 25) == nil)
    }

    @Test func courseWithGoodAccuracyIsKept() {
        #expect(Heading.validCourse(90, accuracy: 5) == 90)
    }

    @Test func courseWithUnknownAccuracyIsInvalid() {
        // Core Location reports a negative courseAccuracy when the course cannot be trusted.
        #expect(Heading.validCourse(90, accuracy: -1) == nil)
    }

    // MARK: Holding the course

    @Test func liveCourseReplacesHeldCourse() {
        #expect(Heading.heldCourse(previous: 180, kmh: 30, course: 90) == 90)
    }

    @Test func heldCourseKeptWhenSlow() {
        // Under 7 km/h GPS course is noise; keep pointing where we last drove.
        #expect(Heading.heldCourse(previous: 180, kmh: 3, course: 90) == 180)
    }

    @Test func heldCourseKeptWhenCourseInvalid() {
        #expect(Heading.heldCourse(previous: 180, kmh: 30, course: nil) == 180)
    }

    @Test func heldCourseKeptWhenSpeedUnknown() {
        #expect(Heading.heldCourse(previous: 180, kmh: nil, course: 90) == 180)
    }

    @Test func noCourseBeforeFirstMovement() {
        #expect(Heading.heldCourse(previous: nil, kmh: 3, course: nil) == nil)
    }

    @Test func courseIsLiveOnlyWhenMovingWithValidCourse() {
        #expect(Heading.isCourseLive(kmh: 30, course: 90))
        #expect(!Heading.isCourseLive(kmh: 3, course: 90))
        #expect(!Heading.isCourseLive(kmh: 30, course: nil))
        #expect(!Heading.isCourseLive(kmh: nil, course: 90))
    }

    // MARK: Cardinal labels

    @Test func cardinalNorthCoversBothSidesOfZero() {
        #expect(Heading.cardinal(0) == "N")
        #expect(Heading.cardinal(20) == "N")
        #expect(Heading.cardinal(340) == "N")
    }

    @Test func cardinalIntermediatePoints() {
        #expect(Heading.cardinal(45) == "NE")
        #expect(Heading.cardinal(135) == "SE")
        #expect(Heading.cardinal(225) == "SW")
        #expect(Heading.cardinal(315) == "NW")
    }

    @Test func cardinalBoundaryRoundsToNearest() {
        // 22.5 is the N/NE boundary; just past it belongs to NE.
        #expect(Heading.cardinal(23) == "NE")
        #expect(Heading.cardinal(22) == "N")
    }
}
