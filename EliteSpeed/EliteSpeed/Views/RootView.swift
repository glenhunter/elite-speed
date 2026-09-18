import CoreLocation
import SwiftUI

/// Picks the landscape or portrait arrangement of the panels and sets the dashboard colour.
struct RootView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    @Environment(MusicModel.self) private var music
    @Environment(SpeedModel.self) private var speed
    @AppStorage(Settings.digitColour) private var digitColour = DigitColour.white
    @AppStorage(Settings.nightMode) private var nightMode = false
    @AppStorage(Settings.showMap) private var showMap = true
    @AppStorage(Settings.showClock) private var showClock = true
    @AppStorage(Settings.showCompass) private var showCompass = true
    @AppStorage(Settings.showMediaControls) private var showMediaControls = true
    @State private var showSettings = false

    private let sideInset: CGFloat = 16

    var body: some View {
        TimelineView(.everyMinute) { context in
            Group {
                if verticalSizeClass == .compact {
                    landscape
                } else {
                    portrait
                }
            }
            .foregroundStyle(foreground(at: context.date))
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

    /// Night-safe red between civil dusk and dawn when enabled, otherwise the chosen preset.
    private func foreground(at date: Date) -> Color {
        if nightMode, let here = speed.coordinate,
           Solar.isNight(at: date, latitude: here.latitude, longitude: here.longitude) {
            return DigitColour.night
        }
        return digitColour.color
    }

    private var showRow: Bool { showClock || showCompass }

    /// [music / clock / compass column] · speed · map
    private var landscape: some View {
        HStack(spacing: 8) {
            if showRow || showMediaControls {
                VStack(spacing: 8) {
                    if showMediaControls { MusicControlsView() }
                    if showClock { ClockView() }
                    if showCompass { CompassView() }
                }
                .frame(maxWidth: 220)
            }
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
            let rowWidth = geometry.size.width - 2 * sideInset
            let shares = PortraitLayout.shares(showMap: showMap, showRow: showRow, showMedia: showMediaControls)
            VStack(spacing: 0) {
                SpeedView(alignment: .bottom)
                    .frame(height: height * shares.speed)
                if showMap {
                    MapPanel()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(height: height * shares.map)
                }
                if showRow {
                    HStack(spacing: 0) {
                        if showClock {
                            ClockView()
                                .frame(width: showCompass ? rowWidth * 2 / 3 : rowWidth)
                        }
                        if showClock && showCompass {
                            Keyline(axis: .vertical)
                                .padding(.vertical, Layout.gap)
                        }
                        if showCompass {
                            CompassView()
                        }
                    }
                    .frame(height: height * shares.row)
                }
                if showMediaControls {
                    if showRow {
                        Keyline(axis: .horizontal)
                    }
                    MusicControlsView()
                        .padding(.vertical, Layout.gap)
                        .frame(height: height * shares.media)
                }
            }
            .padding(.horizontal, sideInset)
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
