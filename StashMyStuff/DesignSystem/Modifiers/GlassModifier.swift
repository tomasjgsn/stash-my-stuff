//
//  GlassModifier.swift
//  StashMyStuff
//
//  Created by Tomas Juergensen on 27/12/2025.
//

import SwiftUI

// MARK: - Glass Card Modifier (with padding)

struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(self.padding)
            .glassEffect(.regular, in: .rect(cornerRadius: self.cornerRadius))
    }
}

// MARK: - Interactive Glass Modifier (for buttons)

struct InteractiveGlassModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: self.cornerRadius))
    }
}

// MARK: - Shadow Modifier

extension View {
    /// Applies a design token shadow (for non-glass elements)
    /// Note: Glass elements don't need this - .glassEffect() handles depth automatically
    func shadow(_ shadow: DesignTokens.Shadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

// MARK: - View Extension

extension View {
    /// Applies a complete glass card style with padding
    func glassCard(
        cornerRadius: CGFloat = DesignTokens.Glass.cardRadius,
        padding: CGFloat = DesignTokens.Spacing.lg
    ) -> some View {
        self.modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            padding: padding
        ))
    }

    /// Applies an interactive glass effect (for buttons, tappable elements)
    /// - Parameter cornerRadius: The corner radius (default: buttonRadius = 12pt)
    func glassButton(
        cornerRadius: CGFloat = DesignTokens.Glass.buttonRadius
    ) -> some View {
        self.modifier(InteractiveGlassModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - Preview

#Preview("All Modifiers") {
    ZStack {
        LinearGradient(
            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Glass cards
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Glass Card")
                        .font(DesignTokens.Typography.headline)
                    Text("Complete glass card with .glassCard() modifier")
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()

                // Category badges
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Category Badges")
                        .font(DesignTokens.Typography.headline)

                    FlowLayout(spacing: DesignTokens.Spacing.xs) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue)
                                .categoryBadge(category)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()

                // Category icons
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Category Icons")
                        .font(DesignTokens.Typography.headline)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                        ForEach(Category.allCases, id: \.self) { category in
                            if let config = CategoryConfig.config(for: category) {
                                Image(systemName: config.icon)
                                    .font(.title)
                                    .categoryAccent(category)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()
            }
            .padding()
        }
    }
}

// FlowLayout is defined in TagInput.swift
