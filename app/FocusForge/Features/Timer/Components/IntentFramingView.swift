import SwiftUI

struct IntentFramingView: View {
    let framing: FramingResult
    let onAccept: (String) -> Void
    let onSkip: () -> Void

    @State private var editedText: String = ""
    @State private var isEditing = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundStyle(.cyan)
                .accessibilityHidden(true)

            Text("Focus Intent")
                .font(.title2.bold())

            VStack(spacing: 12) {
                Text("Your task:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(framing.originalTask)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Divider()
                    .padding(.horizontal, 40)

                Text("Suggested focus:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if isEditing {
                    TextField("Edit your focus intent", text: $editedText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(2...4)
                        .padding(.horizontal)
                } else {
                    Text(framing.reframedTask)
                        .font(.body.weight(.medium))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            Text(framing.motivationalLine)
                .font(.caption)
                .foregroundStyle(.cyan)

            Spacer()

            VStack(spacing: 12) {
                if isEditing {
                    Button("Use Edited Intent") {
                        onAccept(editedText.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } else {
                    Button("Accept") {
                        onAccept(framing.reframedTask)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button("Edit") {
                        editedText = framing.reframedTask
                        isEditing = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Button("Skip", action: onSkip)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }
}
