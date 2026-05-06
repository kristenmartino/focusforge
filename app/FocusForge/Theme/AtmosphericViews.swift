import SwiftUI

// MARK: - Focus Mode Background

/// Near-black canvas with a single subtle radial glow behind the timer.
struct FocusBackground: View {
    var accentColor: Color = FFTheme.Accent.blue

    var body: some View {
        ZStack {
            FFTheme.Background.primary
                .ignoresSafeArea()

            // Subtle ambient glow centered on the timer area
            RadialGradient(
                colors: [
                    accentColor.opacity(0.06),
                    Color.clear,
                ],
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
            .offset(y: -40) // Shift up toward timer position
            .ignoresSafeArea()
        }
    }
}

// MARK: - Reward Mode Background

/// Deep purple atmospheric gradient with layered radial glows.
struct RewardBackground: View {
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    FFTheme.Background.rewardTop,
                    FFTheme.Background.rewardMid,
                    FFTheme.Background.rewardBottom,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Primary purple glow
            RadialGradient(
                colors: [
                    Color(hex: "#B478FF").opacity(0.12),
                    Color(hex: "#8C64DC").opacity(0.04),
                    Color.clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.3),
                startRadius: 0,
                endRadius: 200
            )
            .ignoresSafeArea()

            // Secondary warm glow (lower left)
            RadialGradient(
                colors: [
                    FFTheme.Accent.orange.opacity(0.06),
                    Color.clear,
                ],
                center: UnitPoint(x: 0.35, y: 0.75),
                startRadius: 0,
                endRadius: 100
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Character Scene Background

/// Dark atmospheric background for the character/dressing room tab
/// with a ground plane and ambient glow.
struct CharacterSceneBackground: View {
    var characterColor: Color = FFTheme.Accent.blue

    var body: some View {
        ZStack {
            // Dark gradient
            LinearGradient(
                colors: [
                    FFTheme.Background.primary,
                    FFTheme.Background.tertiary,
                    FFTheme.Background.secondary,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient glow behind character position
            RadialGradient(
                colors: [
                    characterColor.opacity(0.10),
                    Color.clear,
                ],
                center: UnitPoint(x: 0.5, y: 0.35),
                startRadius: 0,
                endRadius: 140
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Ground Plane

/// A subtle horizontal light line with underglow, placed beneath the character.
struct GroundPlane: View {
    var color: Color = Color.white
    var width: CGFloat = 200

    var body: some View {
        VStack(spacing: 2) {
            // Thin light line
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, color.opacity(0.06), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: 1)

            // Soft glow beneath
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.08), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: width * 0.4
                    )
                )
                .frame(width: width * 0.6, height: 12)
        }
    }
}

// MARK: - Reward Particle Field

/// Scattered small dots for the reward celebration background.
struct ParticleField: View {
    let count: Int

    // Deterministic positions from a seed so they don't jump on re-render
    private let particles: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)]

    init(count: Int = 12) {
        self.count = count
        var items: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = []
        for i in 0..<count {
            let seed = Double(i)
            let x = (seed * 0.618033988).truncatingRemainder(dividingBy: 1.0)
            let y = (seed * 0.381966012 + 0.1).truncatingRemainder(dividingBy: 1.0)
            let size = CGFloat(1 + (seed * 0.27).truncatingRemainder(dividingBy: 1.0) * 1.5)
            let opacity = 0.15 + (seed * 0.42).truncatingRemainder(dividingBy: 1.0) * 0.25
            items.append((x: x, y: y, size: size, opacity: opacity))
        }
        self.particles = items
    }

    var body: some View {
        GeometryReader { geo in
            ForEach(0..<particles.count, id: \.self) { i in
                let p = particles[i]
                Circle()
                    .fill(
                        i.isMultiple(of: 2)
                            ? Color(hex: "#FFE0A0").opacity(p.opacity)
                            : Color(hex: "#C8B4FF").opacity(p.opacity)
                    )
                    .frame(width: p.size, height: p.size)
                    .position(
                        x: p.x * geo.size.width,
                        y: p.y * geo.size.height
                    )
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Frosted Card

/// Semi-transparent card with subtle border — the "frosted glass" reward card.
struct FrostedCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(FFTheme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                            .stroke(Color.white.opacity(0.10), lineWidth: 0.5)
                    )
            )
    }
}

// MARK: - Accent Pill Button

/// Gradient-filled CTA button for reward mode.
struct AccentPillButton: View {
    let title: String
    let action: () -> Void
    var style: PillStyle = .purple

    enum PillStyle {
        case purple, blue

        var gradient: [Color] {
            switch self {
            case .purple: [Color(hex: "#7B5FD4"), Color(hex: "#9B6FE4")]
            case .blue: [FFTheme.Accent.blue, Color(hex: "#6B9AFF")]
            }
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.medium))
                .foregroundStyle(FFTheme.Text.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: FFTheme.Radius.md)
                        .fill(
                            LinearGradient(
                                colors: style.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Dark Navigation Appearance

extension View {
    /// Applies the dark atmospheric navigation bar styling.
    func darkNavigationAppearance() -> some View {
        self.toolbarBackground(FFTheme.Background.primary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }

    /// Applies dark atmospheric tab bar styling.
    func darkTabBarAppearance() -> some View {
        self.toolbarBackground(FFTheme.Background.secondary, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
    }
}

#Preview("Focus Background") {
    FocusBackground()
}

#Preview("Reward Background") {
    ZStack {
        RewardBackground()
        ParticleField()
    }
}
