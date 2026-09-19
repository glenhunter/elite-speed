import SwiftUI

@main
struct EliteSpeedApp: App {
    @State private var speed = SpeedModel()
    @State private var music = MusicModel()

    init() {
        Self.keepScreenAwake()
    }

    /// The app only runs in the foreground on a mounted phone; never let the screen dim or lock.
    /// iOS can quietly reset this flag, for example around system alerts such as the permission
    /// prompts on first launch, so it is re-asserted whenever the app becomes active and each minute.
    static func keepScreenAwake() {
        UIApplication.shared.isIdleTimerDisabled = true
    }

    /// `--landscape` or `--portrait` forces the orientation so the Simulator layout can be checked
    /// without rotating it.
    private func applyDebugOrientation() {
        #if DEBUG
        let arguments = CommandLine.arguments
        let wanted: UIInterfaceOrientationMask? = arguments.contains("--landscape") ? .landscapeRight
            : arguments.contains("--portrait") ? .portrait : nil
        guard let wanted, let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: wanted))
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
