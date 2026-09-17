import SwiftUI

/// Picks the landscape or portrait arrangement of the panels.
struct RootView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    @Environment(MusicModel.self) private var music
    @AppStorage(Settings.showMap) private var showMap = true
    @State private var showSettings = false

    var body: some View {
        Group {
            if verticalSizeClass == .compact {
                landscape
            } else {
                portrait
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .overlay(alignment: .topLeading) { settingsButton }
        .overlay(alignment: .top) { NowPlayingToast() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { music.refresh() }
        }
    }

    /// [music / clock / compass column] · speed · map
    private var landscape: some View {
        HStack(spacing: 8) {
            VStack(spacing: 8) {
                MusicControlsView()
                ClockView()
                CompassView()
            }
            .frame(maxWidth: 220)
            SpeedView()
            if showMap {
                MapPanel()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    /// speed · map · [clock | compass] · keyline · music, at fixed shares of the height.
    private var portrait: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            VStack(spacing: 0) {
                SpeedView()
                    .frame(height: height * (showMap ? 0.25 : 0.75))
                if showMap {
                    MapPanel()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(height: height * 0.50)
                }
                HStack(spacing: 0) {
                    ClockView()
                    Keyline(axis: .vertical)
                        .padding(.vertical, 12)
                    CompassView()
                }
                .frame(height: height * 0.12)
                Keyline(axis: .horizontal)
                MusicControlsView()
                    .padding(.vertical, 12)
                    .frame(height: height * 0.13)
            }
            .padding(.horizontal, 16)
        }
    }

    private var settingsButton: some View {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.tertiary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Settings")
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
