import CoreLocation
import SwiftUI

/// Picks the landscape or portrait arrangement of the panels and paints the two livery zones:
/// upper under the speed and map, lower under the clock, compass and controls.
struct RootView: View {
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.scenePhase) private var scenePhase
    @Environment(MusicModel.self) private var music
    @Environment(SpeedModel.self) private var speed
    @AppStorage(Settings.theme) private var theme = Theme.classic
    @AppStorage(Settings.digitColour) private var digitColour = DigitColour.white
    @AppStorage(Settings.nightMode) private var nightMode = false
    @AppStorage(Settings.showMap) private var showMap = true
    @AppStorage(Settings.showClock) private var showClock = true
    @AppStorage(Settings.showCompass) private var showCompass = true
    @AppStorage(Settings.showMediaControls) private var showMediaControls = true
    @State private var showSettings = false

    /// Breathing room between the screen edge and the panels.
    private let edge: CGFloat = 8
    /// Extra inset for the clock and compass row and the controls, and their keylines.
    private let sideInset: CGFloat = 24

    var body: some View {
        TimelineView(.everyMinute) { context in
            let palette = Palette.resolve(theme: theme, digitColour: digitColour, night: isNight(at: context.date))
            Group {
                if verticalSizeClass == .compact {
                    landscape(palette)
                } else {
                    portrait(palette)
                }
            }
            .environment(\.palette, palette)
        }
        .overlay(alignment: .topTrailing) { settingsButton }
        .overlay(alignment: .top) { NowPlayingToast() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { music.refresh() }
        }
    }

    private func isNight(at date: Date) -> Bool {
        guard nightMode, let here = speed.coordinate else { return false }
        return Solar.isNight(at: date, latitude: here.latitude, longitude: here.longitude)
    }

    private var showRow: Bool { showClock || showCompass }
    private var showColumn: Bool { showRow || showMediaControls }

    // MARK: Portrait

    /// speed · map above, [clock | compass] · keyline · music below, at fixed shares of the height.
    private func portrait(_ palette: Palette) -> some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let rowWidth = geometry.size.width - 2 * sideInset
            let speedShare = palette.roundel == nil
                ? 0.25
                : PortraitLayout.roundelPanelHeight(screenWidth: geometry.size.width, sideMargin: Layout.roundelSideMargin, gap: Layout.gap) / height
            let shares = PortraitLayout.shares(showMap: showMap, showRow: showRow, showMedia: showMediaControls, speed: speedShare)
            VStack(spacing: 0) {
                // The upper zone fills whatever the lower panels leave, so hidden panels
                // read as empty livery colour rather than a gap.
                VStack(spacing: 0) {
                    SpeedView(alignment: .bottom, roundelSideInset: Layout.roundelSideMargin - edge)
                        .frame(height: height * shares.speed - (palette.roundel == nil ? edge : 0))
                    if showMap {
                        MapPanel()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .frame(height: height * shares.map)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, palette.roundel == nil ? edge : 0)
                .padding(.horizontal, edge)
                .frame(maxHeight: .infinity)
                .foregroundStyle(palette.upperForeground)
                .background(palette.upperBackground)

                if showColumn {
                    VStack(spacing: 0) {
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
                                .padding(.top, 2 * Layout.gap)
                                .padding(.bottom, Layout.gap)
                                .frame(height: height * shares.media)
                        }
                    }
                    .padding(.horizontal, sideInset)
                    .foregroundStyle(palette.lowerForeground)
                    .background(palette.lowerBackground)
                }
            }
        }
    }

    // MARK: Landscape

    /// [clock / compass / music column] · speed · map, at fixed shares of the width.
    private func landscape(_ palette: Palette) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let shares = LandscapeLayout.shares(showColumn: showColumn, showMap: showMap)
            HStack(spacing: 0) {
                if showColumn {
                    VStack(spacing: 0) {
                        if showClock {
                            ClockView()
                        }
                        if showClock && showCompass {
                            Keyline(axis: .horizontal).padding(.horizontal, Layout.gap)
                        }
                        if showCompass {
                            CompassView()
                        }
                        if showRow && showMediaControls {
                            Keyline(axis: .horizontal).padding(.horizontal, Layout.gap)
                        }
                        if showMediaControls {
                            MusicControlsView()
                                .padding(.top, 2 * Layout.gap)
                                .padding([.horizontal, .bottom], Layout.gap)
                        }
                    }
                    .padding(.vertical, edge)
                    .padding(.leading, edge)
                    .frame(width: width * shares.column)
                    .foregroundStyle(palette.lowerForeground)
                    .background(palette.lowerBackground)
                }
                HStack(spacing: Layout.gap) {
                    SpeedView()
                    if showMap {
                        MapPanel()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .frame(width: width * shares.map - edge - Layout.gap)
                    }
                }
                .padding(.vertical, edge)
                .padding(.trailing, edge)
                .padding(.leading, Layout.gap)
                .frame(width: width * (shares.speed + shares.map))
                .foregroundStyle(palette.upperForeground)
                .background(palette.upperBackground)
            }
        }
    }

    private var settingsButton: some View {
        Button {
            showSettings = true
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial, in: Circle())
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
