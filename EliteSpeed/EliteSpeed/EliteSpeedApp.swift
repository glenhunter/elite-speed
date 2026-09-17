import SwiftUI

@main
struct EliteSpeedApp: App {
    @State private var speed = SpeedModel()
    @State private var music = MusicModel()

    init() {
        // The app only runs in the foreground on a mounted phone; never let the screen lock.
        UIApplication.shared.isIdleTimerDisabled = true
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(speed)
                .environment(music)
        }
    }
}
