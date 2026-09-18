import MapKit
import SwiftUI

/// Map centred on the car, rotating to the direction of travel by default. Pan and zoom only;
/// touch cannot rotate it, so with the setting off it stays north-up.
struct MapPanel: View {
    @AppStorage(Settings.mapFollowsHeading) private var followsHeading = true
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $position, interactionModes: [.pan, .zoom]) {
            UserAnnotation()
        }
        .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll, showsTraffic: false))
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
