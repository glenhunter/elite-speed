import MapKit
import SwiftUI

/// Map driven by the GPS fix: centred on the car at a fixed driving zoom, rotated to the
/// direction of travel when the setting is on. Not interactive; it is a dashboard, not a map app.
struct MapPanel: View {
    @Environment(SpeedModel.self) private var speed
    @AppStorage(Settings.mapFollowsHeading) private var followsHeading = true
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $position, interactionModes: []) {
            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
        .mapControlVisibility(.hidden)
        .onChange(of: speed.fixCount, initial: true) { aim(animated: true) }
        .onChange(of: followsHeading) { aim(animated: true) }
        .accessibilityLabel("Map")
        .accessibilityHidden(true) // Decorative for VoiceOver; the compass and speed carry the information.
    }

    /// Points the camera at the latest fix. One-second linear motion matches the one-fix-a-second
    /// GPS cadence, so the map glides rather than stepping.
    private func aim(animated: Bool) {
        guard let here = speed.coordinate else { return }
        let camera = MapCamera(centerCoordinate: here,
                               distance: MapCameraRule.distance,
                               heading: MapCameraRule.heading(course: speed.heading, rotates: followsHeading),
                               pitch: 0)
        if animated {
            withAnimation(.linear(duration: 1)) { position = .camera(camera) }
        } else {
            position = .camera(camera)
        }
    }
}

#Preview {
    MapPanel()
        .environment(SpeedModel())
}
