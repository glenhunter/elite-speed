import SwiftUI

@main
struct EliteSpeedApp: App {
    @State private var speed = SpeedModel()
    @State private var music = MusicModel()

    init() {
        // The app only runs in the foreground on a mounted phone; never let the screen lock.
        UIApplication.shared.isIdleTimerDisabled = true
    }

    /// `--landscape` forces landscape so the Simulator layout can be checked without rotating it.
    private func applyDebugOrientation() {
        #if DEBUG
        guard CommandLine.arguments.contains("--landscape"),
              let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(speed)
                .environment(music)
                .preferredColorScheme(.dark)
                .onAppear(perform: applyDebugOrientation)
        }
    }
}
