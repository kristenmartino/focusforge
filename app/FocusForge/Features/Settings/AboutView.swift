import SwiftUI

/// The "About FocusForge" screen — surfaces the craft narrative inside the
/// app itself. Reached from Settings → About FocusForge.
///
/// Design intent: this is a quiet, atmospheric screen (focus-mode register,
/// not reward-mode). The user has navigated here deliberately — they're
/// curious about the project. The screen should reward that curiosity with
/// substance, not feature-list bullets.
///
/// Content sections (top → bottom):
/// - Hero: app name, positioning sentence, author attribution
/// - The build: human-written templates count, on-device claim, solo-built signal
/// - Open source: link to the coach engine repo
/// - Links: GitHub, portfolio, privacy, terms
/// - Footer: version + build number
struct AboutView: View {

    var body: some View {
        ZStack {
            FFTheme.Background.primary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: FFTheme.Spacing.xl) {
                    heroBlock
                    buildBlock
                    openSourceBlock
                    linksBlock
                    footerBlock
                }
                .padding(.horizontal, FFTheme.Spacing.lg)
                .padding(.vertical, FFTheme.Spacing.xl)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .darkNavigationAppearance()
    }

    // MARK: - Hero

    private var heroBlock: some View {
        VStack(spacing: FFTheme.Spacing.sm) {
            Text("FocusForge")
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(FFTheme.Text.primary)
                .accessibilityAddTraits(.isHeader)

            Text("Your focus grows your character.")
                .font(.body)
                .foregroundStyle(FFTheme.Text.secondary)
                .multilineTextAlignment(.center)

            Text("A hand-built focus tool by Kristen Martino.")
                .font(.footnote)
                .foregroundStyle(FFTheme.Text.tertiary)
                .padding(.top, FFTheme.Spacing.xs)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, FFTheme.Spacing.md)
        .padding(.bottom, FFTheme.Spacing.xs)
        .accessibilityElement(children: .combine)
    }

    // MARK: - The build

    private var buildBlock: some View {
        FrostedCard {
            VStack(alignment: .leading, spacing: FFTheme.Spacing.md) {
                sectionLabel("The build")

                VStack(alignment: .leading, spacing: FFTheme.Spacing.sm) {
                    factRow(
                        icon: "text.quote",
                        title: "99 pieces of hand-written micro-copy",
                        detail: "33 coach templates × 3 tones, written by one person."
                    )
                    factRow(
                        icon: "iphone.gen3",
                        title: "Coach inference runs on-device",
                        detail: "No cloud LLM. No work data leaves your phone."
                    )
                    factRow(
                        icon: "swift",
                        title: "Solo-built in SwiftUI",
                        detail: "Every screen drawn, every animation hand-tuned."
                    )
                }
            }
        }
    }

    // MARK: - Open source

    private var openSourceBlock: some View {
        Link(destination: URL(string: "https://github.com/kristenmartino/focusforge-coach-engine")!) {
            FrostedCard {
                VStack(alignment: .leading, spacing: FFTheme.Spacing.sm) {
                    HStack(spacing: FFTheme.Spacing.sm) {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                            .font(.title3)
                            .foregroundStyle(FFTheme.Accent.purple)
                            .accessibilityHidden(true)
                        Text("The coach engine is open source")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(FFTheme.Text.primary)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(FFTheme.Text.tertiary)
                            .accessibilityHidden(true)
                    }
                    Text("Read every line a user might see. MIT-licensed on GitHub.")
                        .font(.footnote)
                        .foregroundStyle(FFTheme.Text.secondary)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("The coach engine is open source. Tap to view the repository on GitHub.")
    }

    // MARK: - Links

    private var linksBlock: some View {
        FrostedCard {
            VStack(spacing: 0) {
                linkRow(
                    icon: "globe",
                    label: "Portfolio",
                    url: "https://kristenmartino.ai"
                )
                divider
                linkRow(
                    icon: "swift",
                    label: "App source on GitHub",
                    url: "https://github.com/kristenmartino/focusforge"
                )
                divider
                linkRow(
                    icon: "lock.shield",
                    label: "Privacy Policy",
                    url: "https://kristenmartino.ai/focusforge/privacy"
                )
                divider
                linkRow(
                    icon: "doc.text",
                    label: "Terms of Use",
                    url: "https://kristenmartino.ai/focusforge/terms"
                )
            }
        }
    }

    // MARK: - Footer

    private var footerBlock: some View {
        VStack(spacing: FFTheme.Spacing.xs) {
            Text(Bundle.main.aboutVersionString)
                .font(.footnote.monospacedDigit())
                .foregroundStyle(FFTheme.Text.tertiary)

            Text("Made with care.")
                .font(.caption)
                .foregroundStyle(FFTheme.Text.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, FFTheme.Spacing.md)
        .padding(.bottom, FFTheme.Spacing.lg)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption2.weight(.semibold))
            .tracking(0.8)
            .foregroundStyle(FFTheme.Text.tertiary)
            .accessibilityAddTraits(.isHeader)
    }

    private func factRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: FFTheme.Spacing.sm) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(FFTheme.Accent.blue)
                .frame(width: 22)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(FFTheme.Text.primary)
                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(FFTheme.Text.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func linkRow(icon: String, label: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: FFTheme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(FFTheme.Accent.blue)
                    .frame(width: 22)
                    .accessibilityHidden(true)
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(FFTheme.Text.primary)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(FFTheme.Text.tertiary)
                    .accessibilityHidden(true)
            }
            .padding(.vertical, FFTheme.Spacing.sm)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityHint("Opens in Safari")
    }

    private var divider: some View {
        Rectangle()
            .fill(FFTheme.Border.default)
            .frame(height: 0.5)
    }
}

// MARK: - Bundle version helper

private extension Bundle {
    /// Display string like "Version 1.0 (42)". Used in the About footer.
    var aboutVersionString: String {
        let short = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "Version \(short) (\(build))"
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
    .preferredColorScheme(.dark)
}
