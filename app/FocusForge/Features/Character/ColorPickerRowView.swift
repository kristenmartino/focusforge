import SwiftUI

struct ColorPickerRowView: View {
    let label: String
    let colors: [(name: String, hex: String)]
    @Binding var selectedHex: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                ForEach(colors, id: \.hex) { color in
                    Button {
                        selectedHex = color.hex
                    } label: {
                        Circle()
                            .fill(Color(hex: color.hex))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(selectedHex == color.hex ? Color.primary : Color.clear, lineWidth: 2.5)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color(.systemBackground), lineWidth: 1.5)
                                    .padding(1)
                                    .opacity(selectedHex == color.hex ? 1 : 0)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(color.name) \(label)")
                    .accessibilityAddTraits(selectedHex == color.hex ? .isSelected : [])
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selected = "#E8B894"
    ColorPickerRowView(
        label: "Skin",
        colors: CharacterCatalog.skinColors,
        selectedHex: $selected
    )
    .padding()
}
