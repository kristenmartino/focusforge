import SwiftUI

struct CharacterSelectionStepView: View {
    @Binding var selectedID: String
    let onContinue: () -> Void

    private let presets = CharacterCatalog.presets

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Choose Your Character")
                .font(.title2.bold())

            Text("You can customize them later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                ForEach(presets) { preset in
                    Button {
                        selectedID = preset.id
                    } label: {
                        VStack(spacing: 8) {
                            CharacterSpriteView(
                                loadout: CharacterCatalog.createLoadout(from: preset),
                                size: 90
                            )
                            .frame(width: 100, height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(selectedID == preset.id ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedID == preset.id ? Color.accentColor : Color.clear, lineWidth: 2)
                            )
                            Text(preset.name)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(preset.name) character")
                    .accessibilityAddTraits(selectedID == preset.id ? .isSelected : [])
                }
            }

            Spacer()

            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 40)

            Spacer()
        }
        .onAppear {
            if selectedID.isEmpty || !presets.contains(where: { $0.id == selectedID }) {
                selectedID = presets[0].id
            }
        }
    }
}

#Preview {
    CharacterSelectionStepView(selectedID: .constant("spark"), onContinue: {})
}
