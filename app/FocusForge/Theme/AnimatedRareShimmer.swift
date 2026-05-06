import SwiftUI

/// Continuous shimmer effect for "Animated Rare" cosmetic items (per
/// art-direction-style-guide §4). A soft white band sweeps diagonally
/// across the view on a 2-second loop. Respects accessibilityReduceMotion
/// by falling back to a static sparkle indicator.
struct AnimatedRareShimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if reduceMotion {
            content.overlay(alignment: .topTrailing) {
                Image(systemName: "sparkles")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(FFTheme.Rarity.animatedRare)
                    .padding(6)
                    .accessibilityLabel("Animated rare")
            }
        } else {
            content
                .overlay(
                    GeometryReader { geo in
                        let w = geo.size.width
                        let h = geo.size.height
                        let band = w * 0.5
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.40), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: band, height: h * 1.6)
                        .rotationEffect(.degrees(20))
                        .offset(x: -band + phase * (w + band * 2),
                                y: -h * 0.3)
                        .blendMode(.plusLighter)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                )
                .onAppear {
                    withAnimation(
                        .linear(duration: 2.0).repeatForever(autoreverses: false)
                    ) {
                        phase = 1.0
                    }
                }
        }
    }
}

extension View {
    /// Applies the Animated Rare shimmer effect when condition is true.
    /// Pass the corner radius of the wrapping shape to clip the shimmer
    /// band cleanly. Defaults to FFTheme.Radius.md.
    @ViewBuilder
    func animatedRareShimmer(
        if condition: Bool,
        cornerRadius: CGFloat = FFTheme.Radius.md
    ) -> some View {
        if condition {
            self.modifier(AnimatedRareShimmer(cornerRadius: cornerRadius))
        } else {
            self
        }
    }
}
