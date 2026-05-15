import SwiftUI
import FocusForgeCoachEngine

/// Pre-session coach moment. Shows the reframed version of the user's task
/// with options to accept, edit, or skip. Presented as a medium sheet over
/// the Timer screen before the session starts.
///
/// Design intent: focus-mode register (near-black, restrained). The reframe
/// is the centerpiece of the screen — typography hierarchy makes it the
/// loudest thing. The original task and motivational line are supporting,
/// in dimmer tones. Buttons follow iOS conventions but tinted with the
/// FFTheme accent so they match the rest of the app's interactive surfaces.
struct IntentFramingView: View {
    let framing: FramingResult
    let onAccept: (String) -> Void
    let onSkip: () -> Void

    @State private var editedText: String = ""
    @State private var isEditing = false

    var body: some View {
        ZStack {
            FFTheme.Background.primary.ignoresSafeArea()

            VStack(spacing: FFTheme.Spacing.lg) {
                Spacer()

                // Coach icon with a soft cyan glow halo. The halo adds
                // atmospheric weight so the icon feels like the focal point
                // of the screen rather than a small symbol floating in dark.
                ZStack {
                    Circle()
                        .fill(FFTheme.Accent.cyan.opacity(0.10))
                        .frame(width: 84, height: 84)
                        .blur(radius: 6)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 44))
                        .foregroundStyle(FFTheme.Accent.cyan)
                        .accessibilityHidden(true)
                }

                Text("Focus Intent")
                    .font(.title2.bold())
                    .foregroundStyle(FFTheme.Text.primary)
                    .onAppear {
                        AnalyticsService.track(.aiPromptShown, parameters: [
                            "kind": "intent",
                            "template_id": framing.templateID
                        ])
                    }

                VStack(spacing: FFTheme.Spacing.sm) {
                    sectionLabel("Your task")
                    Text(framing.originalTask)
                        .font(.footnote)
                        .foregroundStyle(FFTheme.Text.tertiary)
                        .multilineTextAlignment(.center)

                    Rectangle()
                        .fill(FFTheme.Border.default)
                        .frame(height: 0.5)
                        .padding(.horizontal, FFTheme.Spacing.xxxl)

                    sectionLabel("Suggested focus")

                    if isEditing {
                        TextField(
                            "Edit your focus intent",
                            text: $editedText,
                            axis: .vertical
                        )
                        .font(.body.weight(.medium))
                        .foregroundStyle(FFTheme.Text.primary)
                        .lineLimit(2...4)
                        .padding(FFTheme.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                                .fill(Color.white.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: FFTheme.Radius.sm)
                                        .stroke(FFTheme.Border.emphasis, lineWidth: 0.5)
                                )
                        )
                        .padding(.horizontal, FFTheme.Spacing.md)
                    } else {
                        Text(framing.reframedTask)
                            .font(.body.weight(.medium))
                            .foregroundStyle(FFTheme.Text.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, FFTheme.Spacing.md)
                    }
                }

                Text(framing.motivationalLine)
                    .font(.caption)
                    .foregroundStyle(FFTheme.Accent.cyan)

                Spacer()

                VStack(spacing: FFTheme.Spacing.sm) {
                    if isEditing {
                        Button("Use Edited Intent") {
                            AnalyticsService.track(.aiSuggestionAccepted, parameters: [
                                "kind": "intent",
                                "edited": true,
                                "template_id": framing.templateID
                            ])
                            onAccept(editedText.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(FFTheme.Accent.blue)
                        .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    } else {
                        Button("Accept") {
                            AnalyticsService.track(.aiSuggestionAccepted, parameters: [
                                "kind": "intent",
                                "edited": false,
                                "template_id": framing.templateID
                            ])
                            onAccept(framing.reframedTask)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .tint(FFTheme.Accent.blue)

                        Button("Edit") {
                            editedText = framing.reframedTask
                            isEditing = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .tint(FFTheme.Accent.blue)
                    }

                    Button("Skip") {
                        AnalyticsService.track(.aiSuggestionDismissed, parameters: [
                            "kind": "intent",
                            "template_id": framing.templateID
                        ])
                        onSkip()
                    }
                    .foregroundStyle(FFTheme.Text.tertiary)
                }

                Spacer()
            }
            .padding()
        }
        .presentationDetents([.medium])
        .presentationBackground(FFTheme.Background.primary)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption2.weight(.semibold))
            .tracking(0.8)
            .foregroundStyle(FFTheme.Text.tertiary)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview {
    IntentFramingView(
        framing: FramingResult(
            templateID: "frm_code_01",
            originalTask: "Refactor the timer engine",
            reframedTask: "Coding session: Refactor the timer engine. What one function or feature will you complete?",
            motivationalLine: "Ship something today!"
        ),
        onAccept: { _ in },
        onSkip: {}
    )
    .preferredColorScheme(.dark)
}
