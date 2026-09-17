import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Settings.showMap) private var showMap = true
    @AppStorage(Settings.mapFollowsHeading) private var mapFollowsHeading = false
    @AppStorage(Settings.units) private var units = SpeedUnit.kmh

    var body: some View {
        NavigationStack {
            Form {
                Picker("Units", selection: $units) {
                    ForEach(SpeedUnit.allCases, id: \.self) { unit in
                        Text(unit.label).tag(unit)
                    }
                }
                .pickerStyle(.segmented)

                Section("Map") {
                    Toggle("Show map", isOn: $showMap)
                    Toggle("Rotate map to heading", isOn: $mapFollowsHeading)
                        .disabled(!showMap)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    SettingsView()
}
