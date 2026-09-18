import Testing
@testable import EliteSpeed

struct MapCameraRuleTests {

    @Test func followsCourseWhenRotationIsOn() {
        #expect(MapCameraRule.heading(course: 90, rotates: true) == 90)
    }

    @Test func northUpWhenRotationIsOff() {
        #expect(MapCameraRule.heading(course: 90, rotates: false) == 0)
    }

    @Test func northUpBeforeFirstCourse() {
        #expect(MapCameraRule.heading(course: nil, rotates: true) == 0)
    }
}
