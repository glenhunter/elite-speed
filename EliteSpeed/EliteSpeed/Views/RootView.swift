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
            let _ = EliteSpeedApp.keepScreenAwake()
            Group {
                if verticalSizeClass == .compact {
                    landscape(palette)
                } else {
                    portrait(palette)
                }
            }
            .environment(\.palette, palette)
        }
        .overlay(alignment: .topTrailing) {
            if verticalSizeClass != .compact { settingsButton }
        }
        .overlay(alignment: .top) { NowPlayingToast() }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                music.refresh()
                EliteSpeedApp.keepScreenAwake()
            }
        }
    }

    private func isNight(at date: Date) -> Bool {
        guard nightMode, let here = speed.coordinate else { return false }
        return Solar.isNight(at: date, latitude: here.latitude, longitude: here.longitude)
    }

    private var showRow: Bool { showClock || showCompass }
    private var showColumn: Bool { showRow || showMediaControls }

    // MARK: Portrait

    /// speed · map above; music · keyline · [clock | compass] below, at fixed shares of the height.
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
                            .frame(height: height * shares.map - Layout.gap)
                            .padding(.bottom, Layout.gap)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, palette.roundel == nil ? edge : 0)
                .padding(.horizontal, edge)
                .frame(maxHeight: .infinity)
                .foregroundStyle(palette.upperForeground)
                .background { upperBackground(palette, axis: .vertical) }

                if showColumn {
                    VStack(spacing: 0) {
                        if showMediaControls {
                            MusicControlsView()
                                .padding(.top, Layout.gap)
                                .padding(.bottom, 2 * Layout.gap)
                                .frame(height: height * shares.media)
                        }
                        if showRow {
                            if showMediaControls {
                                Keyline(axis: .horizontal)
                            }
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
                    }
                    .padding(.horizontal, sideInset)
                    .foregroundStyle(palette.lowerForeground)
                    .background(palette.lowerBackground)
                }
            }
        }
    }

    // MARK: Landscape

    /// Media button height in the landscape column; their width matches the keylines.
    private let landscapeButtonHeight: CGFloat = 64
    /// Widest time the clock can show at its landscape size, for the column width.
    private let clockWidth = Font.speedoWidth(of: "88:88 AM", size: ClockView.fontSize)

    /// [stacked music and now-playing above, clock and compass below] · speed · map. The column is as wide as
    /// its contents need; the speed takes what a full-height roundel wants, or 35:40 with the
    /// map for bare digits. The map runs to the trailing edge, and content runs under the home
    /// indicator so the map's bottom edge matches its top. The gear sits bottom-left of the
    /// green zone, clear of the map.
    private func landscape(_ palette: Palette) -> some View {
        GeometryReader { geometry in
            let columnContent = LandscapeLayout.columnWidth(buttonSize: landscapeButtonHeight,
                                                             clockWidth: clockWidth,
                                                             padding: Layout.gap)
            let keylineWidth = columnContent - 2 * Layout.gap
            let panelHeight = geometry.size.height - 2 * edge
            let roundelNatural: Double? = palette.roundel == nil
                ? nil
                : (panelHeight - 2 * Layout.gap) + 4 * Layout.gap
            let widths = LandscapeLayout.widths(total: geometry.size.width - edge - 2 * Layout.gap,
                                                column: columnContent + edge,
                                                speedNatural: roundelNatural,
                                                showColumn: showColumn, showMap: showMap)
            HStack(spacing: 0) {
                if showColumn {
                    VStack(spacing: 0) {
                        if showMediaControls {
                            MusicControlsView(buttonWidth: keylineWidth, buttonHeight: landscapeButtonHeight, axis: .vertical)
                                .padding(.top, Layout.gap)
                            NowPlayingView()
                                .padding(.top, Layout.gap)
                        }
                        Spacer(minLength: Layout.gap)
                        if showClock {
                            if showMediaControls {
                                Keyline(axis: .horizontal)
                            }
                            ClockView()
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.vertical, Layout.gap)
                        }
                        if showCompass {
                            if showClock || showMediaControls {
                                Keyline(axis: .horizontal)
                            }
                            CompassView()
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, Layout.gap)
                                .padding(.bottom, 2 * Layout.gap)
                        }
                    }
                    .padding(.horizontal, Layout.gap)
                    .padding(.top, edge)
                    .padding(.leading, edge)
                    .frame(width: widths.column)
                    .frame(maxHeight: .infinity)
                    .foregroundStyle(palette.lowerForeground)
                    .background(palette.lowerBackground)
                }
                HStack(spacing: Layout.gap) {
                    SpeedView()
                        .frame(width: widths.speed)
                    if showMap {
                        MapPanel()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .frame(width: widths.map)
                    }
                }
                .padding(.vertical, edge)
                .padding(.leading, Layout.gap)
                .padding(.trailing, edge)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(palette.upperForeground)
                .background { upperBackground(palette, axis: .horizontal) }
                .overlay(alignment: .bottomLeading) {
                    settingsButton.padding(.leading, Layout.gap).padding(.bottom, edge)
                }
            }
        }
        .ignoresSafeArea(.container, edges: [.bottom, .trailing])
    }

    /// Livery colour with any stripes painted over it, extending into the safe areas like the flat colour does.
    private func upperBackground(_ palette: Palette, axis: Axis) -> some View {
        ZStack {
            palette.upperBackground
            if let stripes = palette.stripes {
                StripesView(stripes: stripes, axis: axis)
            }
        }
        .ignoresSafeArea()
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
