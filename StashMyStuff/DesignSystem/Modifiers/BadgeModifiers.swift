//
//  BadgeModifiers.swift
//  StashMyStuff
//
//  Created by Tomas Juergensen on 27/12/2025.
//

import SwiftUI

// MARK: - Favorite Badge Modifier

/// Adds a heart icon overlay to indicate favorited items
struct FavoriteBadgeModifier: ViewModifier {
    let isFavorite: Bool

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if self.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.red)
                        .padding(DesignTokens.Spacing.xs)
                        .glassEffect(.regular, in: .circle)
                        .offset(x: 8, y: -8)
                }
            }
    }
}

extension View {
    /// Adds a favorite heart badge overlay when isFavorite is true
    /// - Parameter isFavorite: Whether to show the heart badge
    func favoriteBadge(isFavorite: Bool) -> some View {
        modifier(FavoriteBadgeModifier(isFavorite: isFavorite))
    }
}

// MARK: - Rotating Glow Highlight

/// Adds a rotating tonal rainbow glow effect based on a single color
struct RotatingGlowModifier: ViewModifier {
    let isActive: Bool
    let color: Color
    let cornerRadius: CGFloat

    @State
    private var rotation: Double = 0

    // Creates a tonal rainbow by shifting hue around the base color
    private var tonalGradientColors: [Color] {
        // Resolve the color to get HSB components
        let uiColor = UIColor(color)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        // Create tonal variations by shifting hue slightly (+/- 30°) and varying saturation/brightness
        return [
            Color(hue: hue - 0.08, saturation: saturation * 0.8, brightness: brightness),
            Color(hue: hue - 0.04, saturation: saturation, brightness: brightness * 1.1),
            self.color, // Base color
            Color(hue: hue + 0.04, saturation: saturation, brightness: brightness * 1.1),
            Color(hue: hue + 0.08, saturation: saturation * 0.8, brightness: brightness),
            Color(hue: hue - 0.08, saturation: saturation * 0.8, brightness: brightness) // Loop back
        ]
    }

    private var tonalGradient: AngularGradient {
        AngularGradient(
            colors: self.tonalGradientColors,
            center: .center,
            angle: .degrees(self.rotation)
        )
    }

    func body(content: Content) -> some View {
        content
            // Outer glow (soft halo)
            .background {
                if self.isActive {
                    RoundedRectangle(cornerRadius: self.cornerRadius)
                        .stroke(self.tonalGradient, lineWidth: 8)
                        .blur(radius: 16)
                        .opacity(0.7)
                }
            }
            // Mid glow
            .overlay {
                if self.isActive {
                    RoundedRectangle(cornerRadius: self.cornerRadius)
                        .stroke(self.tonalGradient, lineWidth: 4)
                        .blur(radius: 3)
                }
            }
            // Sharp border
            .overlay {
                if self.isActive {
                    RoundedRectangle(cornerRadius: self.cornerRadius)
                        .stroke(self.tonalGradient, lineWidth: 2)
                }
            }
            .onAppear {
                guard self.isActive else { return }
                withAnimation(
                    .linear(duration: 2.5)
                        .repeatForever(autoreverses: false)
                ) {
                    self.rotation = 360
                }
            }
            .onChange(of: self.isActive) { _, newValue in
                if newValue {
                    self.rotation = 0
                    withAnimation(
                        .linear(duration: 2.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        self.rotation = 360
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.rotation = 0
                    }
                }
            }
    }
}

extension View {
    /// Adds a rotating tonal glow highlight in a specific color
    /// - Parameters:
    ///   - isActive: Whether to show the animation
    ///   - color: The base color for the tonal rainbow
    ///   - cornerRadius: Corner radius to match your view
    func rotatingGlow(
        _ isActive: Bool,
        color: Color,
        cornerRadius: CGFloat = DesignTokens.Radius.md
    ) -> some View {
        modifier(RotatingGlowModifier(isActive: isActive, color: color, cornerRadius: cornerRadius))
    }

    /// Adds a rotating tonal glow highlight using the category's color
    /// - Parameters:
    ///   - isActive: Whether to show the animation
    ///   - category: The category to get the color from
    ///   - cornerRadius: Corner radius to match your view
    func rotatingGlow(
        _ isActive: Bool,
        category: Category,
        cornerRadius: CGFloat = DesignTokens.Radius.md
    ) -> some View {
        modifier(RotatingGlowModifier(isActive: isActive, color: category.color, cornerRadius: cornerRadius))
    }
}

// MARK: - Preview

#Preview("Badge Modifiers") {
    VStack(spacing: DesignTokens.Spacing.xl) {
        // Favorite badge examples
        Text("Favorite Badges")
            .font(DesignTokens.Typography.headline)

        HStack(spacing: DesignTokens.Spacing.lg) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.blue.opacity(0.3))
                .frame(width: 80, height: 80)
                .favoriteBadge(isFavorite: true)

            RoundedRectangle(cornerRadius: 8)
                .fill(.green.opacity(0.3))
                .frame(width: 80, height: 80)
                .favoriteBadge(isFavorite: false)
        }

        Divider()

        // Rotating tonal glow by category
        VStack(spacing: DesignTokens.Spacing.sm) {
            Text("Tonal Glow by Category")
                .font(DesignTokens.Typography.headline)
            Text("(Run preview to see animation)")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(.secondary)
        }

        HStack(spacing: DesignTokens.Spacing.md) {
            ForEach([Category.recipe, .book, .music, .movie], id: \.self) { category in
                VStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 70, height: 70)
                        .rotatingGlow(true, category: category, cornerRadius: 12)
                    Text(category.rawValue)
                        .font(DesignTokens.Typography.caption)
                }
            }
        }
    }
    .padding()
}
