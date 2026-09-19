import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(Settings.units) private var units = SpeedUnit.kmh
    @AppStorage(Settings.theme) private var theme = Theme.classic
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
                    themeChips
                    if theme == .classic {
                        colourSwatches
                    }
                    Toggle("Night safe colours", isOn: $nightMode)
                } header: {
                    Text("Livery")
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

    private var themeChips: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 12)], spacing: 16) {
            ForEach(Theme.allCases, id: \.self) { candidate in
                let palette = candidate.palette(digitColour: digitColour)
                Button {
                    theme = candidate
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            VStack(spacing: 0) {
                                palette.upperBackground
                                    .overlay {
                                        if let stripes = palette.stripes {
                                            StripesView(stripes: stripes, axis: .vertical)
                                        }
                                    }
                                palette.lowerBackground
                            }
                            if let roundel = palette.roundel {
                                Circle().fill(roundel.fill)
                                    .overlay { if let ring = roundel.ring { Circle().strokeBorder(ring, lineWidth: 1.5) } }
                                    .frame(width: 22, height: 22)
                                    .offset(y: -8)
                            } else {
                                Text("88")
                                    .font(.speedo(.medium, size: 20))
                                    .foregroundStyle(palette.upperForeground)
                                    .offset(y: -8)
                            }
                        }
                        .frame(width: 64, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(.primary, lineWidth: theme == candidate ? 2.5 : 0.5)
                                .opacity(theme == candidate ? 1 : 0.3)
                        }
                        Text(candidate.label)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(theme == candidate ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(candidate.label)
                .accessibilityAddTraits(theme == candidate ? [.isSelected] : [])
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Livery")
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
