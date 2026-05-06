import SwiftUI

struct CharacterSelectionStepView: View {
    @Binding var selectedID: String
    let onContinue: () -> Void

    private let presets = CharacterCatalog.presets

    var body: some View {
        ZStack {
            FFTheme.Background.primary.ignoresSafeArea()

            // Subtle glow behind characters
            RadialGradient(
                colors: [
                    FFTheme.Accent.purple.opacity(0.06),
                    Color.clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.42),
                startRadius: 0,
                endRadius: 180
            )
            .ignoresSafeArea()

            VStack(spacing: FFTheme.Spacing.xl) {
                Spacer()

                VStack(spacing: FFTheme.Spacing.xs) {
                    Text("Choose Your Character")
                        .font(.title2.bold())
                        .foregroundStyle(FFTheme.Text.primary)

                    Text("You can customize them later.")
                        .font(.subheadline)
                        .foregroundStyle(FFTheme.Text.tertiary)
                }

                HStack(spacing: FFTheme.Spacing.md) {
                    ForEach(presets) { preset in
                        Button {
                            selectedID = preset.id
                        } label: {
                            VStack(spacing: FFTheme.Spacing.xs) {
                                CharacterSpriteView(
                                    loadout: CharacterCatalog.createLoadout(from: preset),
                                    size: 80
                                )
                                .frame(width: 90, height: 90)
                                .background(
                                    RoundedRectangle(cornerRadius: FFTheme.Radius.lg)
                                        .fill(
                                            selectedID == preset.id
                                                ? FFTheme.Accent.blue.opacity(0.10)
                                                : Color.white.opacity(0.04)
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: FFTheme.Radius.lg)
                                        .stroke(
                                            selectedID == preset.id
                                                ? FFTheme.Accent.blue.opacity(0.5)
                                                : FFTheme.Border.default,
                                            lineWidth: selectedID == preset.id ? 1.5 : 0.5
                                        )
                                )

                                Text(preset.name)
                                    .font(.caption)
                                    .foregroundStyle(
                                        selectedID == preset.id
                                            ? FFTheme.Text.primary
                                            : FFTheme.Text.tertiary
                                    )
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(preset.name) character")
                        .accessibilityAddTraits(selectedID == preset.id ? .isSelected : [])
                    }
                }

                Spacer()

                AccentPillButton(title: "Continue", action: onContinue, style: .blue)
                    .padding(.horizontal, 40)

                Spacer()
                    .frame(height: FFTheme.Spacing.xxxl)
            }
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
