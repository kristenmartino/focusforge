import SwiftUI

struct FirstSessionNudgeView: View {
    let selectedCharacterID: String
    let onComplete: () -> Void

    /// Build a transient (unsaved) loadout from the chosen preset so the user
    /// sees the character they just picked. The persisted CharacterLoadout
    /// only exists after `completeOnboarding` runs, so this is a one-screen
    /// preview from the preset definition.
    private var previewLoadout: CharacterLoadout? {
        guard let preset = CharacterCatalog.presets.first(where: { $0.id == selectedCharacterID }) else {
            return nil
        }
        return CharacterCatalog.createLoadout(from: preset)
    }

    var body: some View {
        ZStack {
            FFTheme.Background.primary.ignoresSafeArea()

            RadialGradient(
                colors: [
                    FFTheme.Accent.green.opacity(0.08),
                    Color.clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.35),
                startRadius: 0,
                endRadius: 220
            )
            .ignoresSafeArea()

            VStack(spacing: FFTheme.Spacing.xl) {
                Spacer()

                if let loadout = previewLoadout {
                    ZStack {
                        CharacterSpriteView(loadout: loadout, size: 160)
                    }
                    .frame(height: 180)
                    .overlay(alignment: .bottom) {
                        GroundPlane(
                            color: Color(hex: loadout.bodyColorHex),
                            width: 140
                        )
                        .offset(y: 4)
                    }
                    .accessibilityLabel("Your character is ready")
                } else {
                    // Fallback if the preset can't resolve — keep the original timer icon.
                    Image(systemName: "timer")
                        .font(.system(size: 60))
                        .foregroundStyle(FFTheme.Accent.green)
                        .accessibilityHidden(true)
                }

                VStack(spacing: FFTheme.Spacing.xs) {
                    Text("You're All Set!")
                        .font(.title2.bold())
                        .foregroundStyle(FFTheme.Text.primary)

                    Text("Start your first focus session\nand begin building your character.")
                        .font(.body)
                        .foregroundStyle(FFTheme.Text.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Spacer()

                AccentPillButton(title: "Start Focusing", action: onComplete, style: .blue)
                    .padding(.horizontal, 40)

                Spacer()
                    .frame(height: FFTheme.Spacing.xxxl)
            }
        }
    }
}

#Preview {
    FirstSessionNudgeView(selectedCharacterID: "spark", onComplete: {})
}
