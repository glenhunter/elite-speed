import SwiftUI

/// Picks the landscape or portrait arrangement of the panels.
struct RootView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    @Environment(MusicModel.self) private var music
    @AppStorage(Settings.showMap) private var showMap = true

    var body: some View {
        Group {
            if verticalSizeClass == .compact {
                landscape
            } else {
                portrait
            }
        }
        .overlay(alignment: .bottom) { NowPlayingToast() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { music.refresh() }
        }
    }

    /// [music / clock / compass column] · speed · map
    private var landscape: some View {
        HStack {
            VStack {
                MusicControlsView()
                ClockView()
                CompassView()
            }
            SpeedView()
            if showMap {
                MapPanel()
            }
        }
    }

    /// speed · map · [clock + compass row] · music
    private var portrait: some View {
        VStack {
            SpeedView()
            if showMap {
                MapPanel()
            }
            HStack {
                ClockView()
                CompassView()
            }
            MusicControlsView()
        }
    }
}

#Preview("Portrait") {
    RootView()
        .environment(SpeedModel())
        .environment(MusicModel())
}

#Preview("Landscape", traits: .landscapeLeft) {
    RootView()
        .environment(SpeedModel())
        .environment(MusicModel())
}
