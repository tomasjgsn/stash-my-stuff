//
//  DesignTokens.swift
//  StashMyStuff
//
//  Created by Tomas Juergensen on 27/12/2025.
//

import Foundation
import SwiftUI

// MARK: Color Extension for Hex

extension Color {
    // Creates a color from a hex string
    init(hex: String) {
        // Remove # if present
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RGB (no alpha)
            (r, g, b, a) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF, 255)
        case 8: // RGBA
            (r, g, b, a) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: Design Tokens

enum DesignTokens {
    enum Colors {
        // MARK: Category Colors

        // These match our CategoryConfig colors but as actual SwiftUI Colors
        static let categoryRecipe = Color.orange
        static let categoryBook = Color.indigo
        static let categoryMovie = Color.purple
        static let categoryMusic = Color.pink
        static let categoryClothes = Color.teal
        static let categoryHome = Color.brown
        static let categoryArticle = Color.blue
        static let categoryPodcast = Color.green
        static let categoryTrip = Color.cyan
        static let categoryBackpack = Color.gray

        // MARK: Semantic Colors

        static let primary = Color.primary // Main text
        static let secondary = Color.secondary // Subtitle text
        static let accent = Color.accentColor // Tappable elements
        static let background = Color(.systemBackground)
        static let secondaryBackground = Color(.secondarySystemBackground)
        static let tertiaryBackground = Color(.tertiarySystemBackground)

        // MARK: Feedback Colors

        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
    }

    // MARK: - Glass Effect Configuration

    // iOS 26+ uses .glassEffect() modifier for native Liquid Glass
    // API: .glassEffect(_ style: GlassEffectStyle, in shape: some Shape)
    //
    // Glass styles:
    //   .regular              - Standard glass for cards/containers
    //   .regular.interactive  - For tappable elements (buttons, rows)
    //
    // Common patterns:
    //   .glassEffect()                                                  // Default
    //   .glassEffect(.regular, in: .rect(cornerRadius: 16))             // Card
    //   .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12)) // Button
    //   .glassEffect(.regular, in: .capsule)                            // Pill
    enum Glass {
        /// Corner radius for standard glass cards
        static let cardRadius: CGFloat = Radius.lg

        /// Corner radius for glass buttons
        static let buttonRadius: CGFloat = Radius.md

        /// Corner radius for small glass elements (tags, chips)
        static let chipRadius: CGFloat = Radius.sm
    }

    enum Spacing {
        /// 4pt - Minimal spacing (between icon and label)
        static let xxs: CGFloat = 4

        /// 8pt - Small spacing (list item padding)
        static let xs: CGFloat = 8

        /// 12pt - Medium-small spacing
        static let sm: CGFloat = 12

        /// 16pt - Medium spacing (standard padding)
        static let md: CGFloat = 16

        /// 20pt - Medium-large spacing
        static let lg: CGFloat = 20

        /// 24pt - Large spacing (section separation)
        static let xl: CGFloat = 24

        /// 32pt - Extra large spacing
        static let xxl: CGFloat = 32
    }

    // MARK: - Typography

    enum Typography {
        // Font sizes following Apple's Human Interface Guidelines
        static let largeTitle: Font = .largeTitle // 34pt
        static let title: Font = .title // 28pt
        static let title2: Font = .title2 // 22pt
        static let title3: Font = .title3 // 20pt
        static let headline: Font = .headline // 17pt semibold
        static let body: Font = .body // 17pt
        static let callout: Font = .callout // 16pt
        static let subheadline: Font = .subheadline // 15pt
        static let footnote: Font = .footnote // 13pt
        static let caption: Font = .caption // 12pt
        static let caption2: Font = .caption2 // 11pt

        // Custom variants using SF Pro Rounded (app's personality)
        static let titleRounded: Font = .system(.title, design: .rounded, weight: .bold)
        static let headlineRounded: Font = .system(.headline, design: .rounded, weight: .semibold)
        static let bodyRounded: Font = .system(.body, design: .rounded)
    }

    // MARK: - Radius (Corner Radii)

    enum Radius {
        /// 4pt - Subtle rounding (small buttons)
        static let xs: CGFloat = 4

        /// 8pt - Small rounding (chips, tags)
        static let sm: CGFloat = 8

        /// 12pt - Medium rounding (buttons, inputs)
        static let md: CGFloat = 12

        /// 16pt - Large rounding (cards)
        static let lg: CGFloat = 16

        /// 20pt - Extra large rounding (glass cards)
        static let xl: CGFloat = 20

        /// Full circle (for circular buttons/avatars)
        static func circle(size: CGFloat) -> CGFloat {
            size / 2
        }
    }

    // MARK: - Animation Durations

    enum AnimationDuration {
        /// 0.15s - Quick interactions (button taps, toggles)
        static let quick = 0.15

        /// 0.3s - Standard transitions (navigation, modals)
        static let standard = 0.3

        /// 0.5s - Slow, deliberate animations (onboarding, emphasis)
        static let slow = 0.5
    }

    // MARK: - Icon Sizes

    enum IconSize {
        /// 16pt - Small icons (inline with text)
        static let sm: CGFloat = 16

        /// 24pt - Medium icons (list items, buttons)
        static let md: CGFloat = 24

        /// 32pt - Large icons (headers, emphasis)
        static let lg: CGFloat = 32

        /// 44pt - Extra large (Apple's minimum tap target)
        static let xl: CGFloat = 44
    }

    // MARK: - Shadows

    // Note: iOS 26 Liquid Glass handles shadows automatically via .glassEffect()
    // These are retained for non-glass elements that need manual shadows
    enum Shadows {
        /// Standard shadow color that adapts to light/dark mode
        static let shadowColor = Color.black.opacity(0.15)

        /// Subtle shadow for slight elevation
        static let sm = Shadow(
            color: shadowColor,
            radius: 4,
            x: 0,
            y: 2
        )

        /// Medium shadow for cards
        static let md = Shadow(
            color: shadowColor,
            radius: 8,
            x: 0,
            y: 4
        )

        /// Large shadow for modals/sheets
        static let lg = Shadow(
            color: shadowColor,
            radius: 16,
            x: 0,
            y: 8
        )
    }

    // Shadow struct to hold all values together
    struct Shadow {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Category Color Extension

extension Category {
    /// Returns the SwiftUI Color for this category
    var color: Color {
        switch self {
        case .recipe: DesignTokens.Colors.categoryRecipe
        case .book: DesignTokens.Colors.categoryBook
        case .movie: DesignTokens.Colors.categoryMovie
        case .music: DesignTokens.Colors.categoryMusic
        case .clothes: DesignTokens.Colors.categoryClothes
        case .home: DesignTokens.Colors.categoryHome
        case .article: DesignTokens.Colors.categoryArticle
        case .podcast: DesignTokens.Colors.categoryPodcast
        case .trip: DesignTokens.Colors.categoryTrip
        case .backpack: DesignTokens.Colors.categoryBackpack
        }
    }
}

// MARK: - Preview

#Preview("Design Tokens") {
    ZStack {
        // Colorful background to show glass effects
        LinearGradient(
            colors: [.blue, .purple, .pink, .orange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                // Liquid Glass Demo
                Text("Liquid Glass")
                    .font(DesignTokens.Typography.titleRounded)
                    .foregroundStyle(.white)

                HStack(spacing: DesignTokens.Spacing.md) {
                    // Default glass
                    glassCard(label: "Default\n.glassEffect()")

                    // Interactive glass (for buttons)
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                            .fill(.white.opacity(0.1))
                            .frame(height: 80)

                        Text("Interactive\n.interactive()")
                            .font(DesignTokens.Typography.caption)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding(DesignTokens.Spacing.sm)
                    .frame(maxWidth: .infinity)
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: DesignTokens.Glass.buttonRadius))
                }

                Divider()
                    .background(.white.opacity(0.3))

                // Category Colors
                Text("Category Colors")
                    .font(DesignTokens.Typography.titleRounded)
                    .foregroundStyle(.white)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: DesignTokens.Spacing.sm) {
                    ForEach(Category.allCases, id: \.self) { category in
                        VStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 44, height: 44)
                            Text(category.rawValue)
                                .font(DesignTokens.Typography.caption)
                                .lineLimit(1)
                        }
                        .padding(DesignTokens.Spacing.xs)
                        .glassEffect(.regular, in: .rect(cornerRadius: DesignTokens.Glass.chipRadius))
                    }
                }

                Divider()
                    .background(.white.opacity(0.3))

                // Spacing Demo
                Text("Spacing Scale")
                    .font(DesignTokens.Typography.titleRounded)
                    .foregroundStyle(.white)

                HStack(spacing: 0) {
                    spacingBox(DesignTokens.Spacing.xxs, "xxs")
                    spacingBox(DesignTokens.Spacing.xs, "xs")
                    spacingBox(DesignTokens.Spacing.sm, "sm")
                    spacingBox(DesignTokens.Spacing.md, "md")
                    spacingBox(DesignTokens.Spacing.lg, "lg")
                    spacingBox(DesignTokens.Spacing.xl, "xl")
                }
                .padding(DesignTokens.Spacing.md)
                .glassEffect(.regular, in: .rect(cornerRadius: DesignTokens.Glass.cardRadius))

                Divider()
                    .background(.white.opacity(0.3))

                // Typography Demo
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Typography")
                        .font(DesignTokens.Typography.titleRounded)
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text("Large Title").font(DesignTokens.Typography.largeTitle)
                        Text("Title").font(DesignTokens.Typography.title)
                        Text("Headline").font(DesignTokens.Typography.headline)
                        Text("Body").font(DesignTokens.Typography.body)
                        Text("Caption").font(DesignTokens.Typography.caption)

                        Divider().background(.white.opacity(0.2))

                        Text("Title Rounded").font(DesignTokens.Typography.titleRounded)
                        Text("Body Rounded").font(DesignTokens.Typography.bodyRounded)
                    }
                    .padding(DesignTokens.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassEffect(.regular, in: .rect(cornerRadius: DesignTokens.Glass.cardRadius))
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
    }
}

@ViewBuilder
private func glassCard(label: String) -> some View {
    VStack(spacing: DesignTokens.Spacing.xs) {
        RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
            .fill(.white.opacity(0.1))
            .frame(height: 80)

        Text(label)
            .font(DesignTokens.Typography.caption)
            .multilineTextAlignment(.center)
            .lineLimit(2)
    }
    .padding(DesignTokens.Spacing.sm)
    .frame(maxWidth: .infinity)
    .glassEffect(.regular, in: .rect(cornerRadius: DesignTokens.Glass.cardRadius))
}

@ViewBuilder
private func spacingBox(_ size: CGFloat, _ label: String) -> some View {
    VStack {
        Rectangle()
            .fill(DesignTokens.Colors.accent)
            .frame(width: size, height: 40)
        Text(label)
            .font(DesignTokens.Typography.caption2)
        Text("\(Int(size))pt")
            .font(DesignTokens.Typography.caption2)
            .foregroundStyle(DesignTokens.Colors.secondary)
    }
    .padding(.horizontal, 4)
}
