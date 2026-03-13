import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HStack {
        StatCardView(title: "Sessions", value: "12", icon: "checkmark.circle.fill", color: .green)
        StatCardView(title: "Minutes", value: "300", icon: "clock.fill", color: .blue)
    }
    .padding()
}
