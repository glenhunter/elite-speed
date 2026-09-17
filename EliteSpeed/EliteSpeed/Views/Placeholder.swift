import SwiftUI

/// Labelled, bordered stand-in used until each panel gets its real content.
struct Placeholder: View {
    let label: String

    var body: some View {
        Text(label)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .border(.secondary)
    }
}
