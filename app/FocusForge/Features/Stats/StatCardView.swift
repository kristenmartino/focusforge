import SwiftUI

struct StatCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: FFTheme.Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.statNumber)
                .foregroundStyle(FFTheme.Text.primary)

            Text(title)
                .font(.statLabel)
                .foregroundStyle(FFTheme.Text.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(FFTheme.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                .fill(color.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                        .stroke(color.opacity(0.10), lineWidth: 0.5)
                )
        )
    }
}

#Preview {
    ZStack {
        FFTheme.Background.primary.ignoresSafeArea()
        HStack {
            StatCardView(
                title: "Sessions",
                value: "12",
                icon: "checkmark.circle.fill",
                color: FFTheme.Accent.green
            )
            StatCardView(
                title: "Minutes",
                value: "300",
                icon: "clock.fill",
                color: FFTheme.Accent.blue
            )
        }
        .padding()
    }
}
