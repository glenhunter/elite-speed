import MapKit
import SwiftUI

/// North-up map centred on the car. Pan and zoom only; no rotate, so north stays up
/// unless the follows-heading setting is on.
struct MapPanel: View {
    @AppStorage(Settings.mapFollowsHeading) private var followsHeading = false
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $position, interactionModes: [.pan, .zoom]) {
            UserAnnotation()
        }
        .mapStyle(.standard(emphasis: .muted))
        .mapControls { MapUserLocationButton() }
        .onAppear(perform: followUser)
        .onChange(of: followsHeading) { followUser() }
        .accessibilityLabel("Map")
    }

    private func followUser() {
        position = .userLocation(followsHeading: followsHeading, fallback: .automatic)
    }
}

#Preview {
    MapPanel()
}
