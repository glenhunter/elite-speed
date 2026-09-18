import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Settings.units) private var units = SpeedUnit.kmh
    @AppStorage(Settings.digitColour) private var digitColour = DigitColour.white
    @AppStorage(Settings.nightMode) private var nightMode = false
    @AppStorage(Settings.showMap) private var showMap = true
    @AppStorage(Settings.mapFollowsHeading) private var mapFollowsHeading = true
    @AppStorage(Settings.showClock) private var showClock = true
    @AppStorage(Settings.clockFormat) private var clockFormat = ClockFormat.system
    @AppStorage(Settings.showCompass) private var showCompass = true
    @AppStorage(Settings.showMediaControls) private var showMediaControls = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Speed") {
                    Picker("Units", selection: $units) {
                        ForEach(SpeedUnit.allCases, id: \.self) { unit in
                            Text(unit.label).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    colourSwatches
                    Toggle("Night safe colours", isOn: $nightMode)
                } header: {
                    Text("Colour")
                } footer: {
                    Text("Night safe colours turn the dashboard red between dusk and dawn, worked out from your position.")
                }

                Section("Map") {
                    Toggle("Show map", isOn: $showMap)
                    Toggle("Rotate map to heading", isOn: $mapFollowsHeading)
                        .disabled(!showMap)
                }

                Section("Clock") {
                    Toggle("Show clock", isOn: $showClock)
                    Picker("Format", selection: $clockFormat) {
                        ForEach(ClockFormat.allCases, id: \.self) { format in
                            Text(format.label).tag(format)
                        }
                    }
                    .disabled(!showClock)
                }

                Section("Panels") {
                    Toggle("Show compass", isOn: $showCompass)
                    Toggle("Show media controls", isOn: $showMediaControls)
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
        .presentationDetents([.large])
    }

    private var colourSwatches: some View {
        HStack(spacing: 16) {
            ForEach(DigitColour.allCases, id: \.self) { preset in
                Button {
                    digitColour = preset
                } label: {
                    Circle()
                        .fill(preset.color)
                        .frame(width: 36, height: 36)
                        .overlay {
                            Circle().strokeBorder(.primary, lineWidth: digitColour == preset ? 3 : 0)
                                .padding(-4)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(preset.label)
                .accessibilityAddTraits(digitColour == preset ? [.isSelected] : [])
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Digit colour")
    }
}

#Preview {
    SettingsView()
}
