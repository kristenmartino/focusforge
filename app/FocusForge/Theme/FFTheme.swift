import SwiftUI

// MARK: - FocusForge Design System

/// Central design tokens for the dark atmospheric UI.
/// Focus mode: near-black, restrained, tool-like.
/// Reward mode: deep purple atmosphere, rich, celebratory.
enum FFTheme {

    // MARK: - Backgrounds

    enum Background {
        /// Near-black with a cool blue undertone — focus mode canvas
        static let primary = Color(hex: "#0A0A0F")
        /// Slightly elevated surface — cards, sheets
        static let secondary = Color(hex: "#0E0E1A")
        /// Mid-tone for dressing room and deeper surfaces
        static let tertiary = Color(hex: "#161628")

        /// Reward mode gradient stops (use in LinearGradient)
        static let rewardTop = Color(hex: "#0C0820")
        static let rewardMid = Color(hex: "#241850")
        static let rewardBottom = Color(hex: "#0C0820")
    }

    // MARK: - Text
    //
    // Opacities chosen to meet WCAG 2.1 AA contrast (4.5:1) on
    // Background.primary (#0A0A0F). Hierarchy is preserved through
    // typography (size/weight) rather than opacity alone, since
    // dropping below ~0.45 fails AA Normal on near-black surfaces.
    // - primary    16.57:1 — headlines, timer
    // - secondary   5.30:1 — labels, descriptions
    // - tertiary    5.30:1 — hints, less critical (use smaller fonts to differentiate)
    // - disabled    1.46:1 — disabled state only (WCAG 1.4.3 exempt)

    enum Text {
        static let primary = Color.white.opacity(0.92)
        static let secondary = Color.white.opacity(0.50)
        static let tertiary = Color.white.opacity(0.50)
        static let disabled = Color.white.opacity(0.15)
    }

    // MARK: - Accent Colors

    enum Accent {
        /// Focus ring, primary interactive elements
        static let blue = Color(hex: "#4A7BF7")
        /// Reward mode CTAs, rare items
        static let purple = Color(hex: "#7B5FD4")
        /// Streak badges, coin indicators
        static let orange = Color(hex: "#F0A040")
        /// XP indicators
        static let gold = Color(hex: "#F0C840")
        /// Streak freeze
        static let cyan = Color(hex: "#60C8FF")
        /// Completed states
        static let green = Color(hex: "#4CAF50")
        /// Destructive actions
        static let red = Color(hex: "#FF5A5A")
    }

    // MARK: - Borders

    enum Border {
        static let `default` = Color.white.opacity(0.06)
        static let emphasis = Color.white.opacity(0.12)
        static let selected = Color.white.opacity(0.20)
    }

    // MARK: - Rarity
    //
    // Brightened from style-guide §6.2 hex values to meet WCAG AA
    // contrast (4.5:1) when used as text on Background.primary. The
    // muted style-guide colors (#888888 / #9B59B6 / #E67E22) work for
    // borders and decorative fills (not subject to text contrast req)
    // but failed AA when applied as a text foreground. New values:
    // - common        5.57:1 (already passes)
    // - rare          6.25:1 (was 4.23 — failed)
    // - animatedRare  6.93:1 (already passes)

    enum Rarity {
        static let common = Color(hex: "#888888")
        static let rare = Color(hex: "#B07DCB")
        static let animatedRare = Color(hex: "#E67E22")
    }

    // MARK: - Spacing Scale

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 40
    }

    // MARK: - Corner Radius

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 10
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    // MARK: - Session Type Colors

    static func sessionColor(for phase: SessionPhase) -> Color {
        switch phase {
        case .focus: Accent.blue
        case .shortBreak: Accent.green
        case .longBreak: Accent.orange
        }
    }
}

// MARK: - Timer Typography

extension Font {
    /// Ultra-thin monospaced timer display (56pt)
    static let timerDisplay: Font = .system(size: 56, weight: .thin, design: .monospaced)
    /// Session type label (11pt, uppercase)
    static let sessionLabel: Font = .system(size: 11, weight: .regular)
    /// Reward headline (22pt)
    static let rewardHeadline: Font = .system(size: 22, weight: .medium)
    /// Reward subhead (13pt)
    static let rewardSubhead: Font = .system(size: 13, weight: .regular)
    /// Stat number (24pt)
    static let statNumber: Font = .system(size: 24, weight: .medium)
    /// Stat label (11pt)
    static let statLabel: Font = .system(size: 11, weight: .regular)
}
