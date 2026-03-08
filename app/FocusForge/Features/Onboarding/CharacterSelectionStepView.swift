import SwiftUI

struct CharacterSelectionStepView: View {
    @Binding var selectedID: String
    let onContinue: () -> Void

    private let characters = [
        ("default", "person.fill", "Explorer"),
        ("scholar", "book.fill", "Scholar"),
        ("builder", "hammer.fill", "Builder"),
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Choose Your Character")
                .font(.title2.bold())

            Text("You can customize them later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 20) {
                ForEach(characters, id: \.0) { id, icon, name in
                    Button {
                        selectedID = id
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: icon)
                                .font(.system(size: 40))
                                .frame(width: 80, height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedID == id ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedID == id ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                            Text(name)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(name) character")
                    .accessibilityAddTraits(selectedID == id ? .isSelected : [])
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
    }
}

#Preview {
    CharacterSelectionStepView(selectedID: .constant("default"), onContinue: {})
}
