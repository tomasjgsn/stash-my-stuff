//
//  ButtonStyles.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Primary Button Style

/// A prominent filled button for primary actions
struct PrimaryButtonStyle: ButtonStyle {
    let color: Color

    init(color: Color = .accentColor) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(self.color)
            }
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    /// Primary filled button style
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }

    /// Primary button with custom color
    static func primary(color: Color) -> PrimaryButtonStyle {
        PrimaryButtonStyle(color: color)
    }
}

// MARK: - Secondary Button Style

/// A bordered button for secondary actions
struct SecondaryButtonStyle: ButtonStyle {
    let color: Color

    init(color: Color = .accentColor) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.headline)
            .foregroundStyle(self.color)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .stroke(self.color, lineWidth: 1.5)
            }
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
    static func secondary(color: Color) -> SecondaryButtonStyle {
        SecondaryButtonStyle(color: color)
    }
}

// MARK: - Ghost Button Style

/// A minimal text-only button
struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.body)
            .foregroundStyle(configuration.isPressed ? .secondary : .primary)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GhostButtonStyle {
    static var ghost: GhostButtonStyle { GhostButtonStyle() }
}

// MARK: - Icon Button Style

/// A circular button for icon-only actions
struct IconButtonStyle: ButtonStyle {
    let size: CGFloat
    let backgroundColor: Color

    init(size: CGFloat = 44, backgroundColor: Color = .clear) {
        self.size = size
        self.backgroundColor = backgroundColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: self.size, height: self.size)
            .background {
                Circle()
                    .fill(self.backgroundColor)
            }
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == IconButtonStyle {
    static var icon: IconButtonStyle { IconButtonStyle() }
    static func icon(size: CGFloat, backgroundColor: Color = .clear) -> IconButtonStyle {
        IconButtonStyle(size: size, backgroundColor: backgroundColor)
    }
}

// MARK: - Custom Glass Button Style

/// A button with glass morphism effect using design tokens
/// Note: Named "stashGlass" to avoid conflict with SwiftUI's built-in .glass style
struct StashGlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.headline)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: DesignTokens.Radius.md))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == StashGlassButtonStyle {
    static var stashGlass: StashGlassButtonStyle { StashGlassButtonStyle() }
}

// MARK: - Destructive Button Style (Exercise 1)

/// A button style for delete/destructive actions
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(Color.red)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == DestructiveButtonStyle {
    static var destructive: DestructiveButtonStyle { DestructiveButtonStyle() }
}

// MARK: - Loading Button Style (Exercise 2)

/// A button style that shows a spinner when loading
struct LoadingButtonStyle: ButtonStyle {
    let isLoading: Bool
    let color: Color

    init(isLoading: Bool, color: Color = .accentColor) {
        self.isLoading = isLoading
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            if self.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            }

            configuration.label
                .opacity(self.isLoading ? 0.7 : 1.0)
        }
        .font(DesignTokens.Typography.headline)
        .foregroundStyle(.white)
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .fill(self.color)
        }
        .opacity(configuration.isPressed && !self.isLoading ? 0.8 : 1.0)
        .scaleEffect(configuration.isPressed && !self.isLoading ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        .allowsHitTesting(!self.isLoading)
    }
}

extension ButtonStyle where Self == LoadingButtonStyle {
    static func loading(isLoading: Bool, color: Color = .accentColor) -> LoadingButtonStyle {
        LoadingButtonStyle(isLoading: isLoading, color: color)
    }
}

// MARK: - Preview

#Preview("Button Styles") {
    ZStack {
        LinearGradient(
            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Primary buttons
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Primary Buttons")
                        .font(DesignTokens.Typography.headline)

                    HStack(spacing: DesignTokens.Spacing.md) {
                        Button("Default") {}
                            .buttonStyle(.primary)

                        Button("Custom") {}
                            .buttonStyle(.primary(color: .orange))

                        Button("Destructive") {}
                            .buttonStyle(.primary(color: .red))
                    }
                }

                Divider()

                // Secondary buttons
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Secondary Buttons")
                        .font(DesignTokens.Typography.headline)

                    HStack(spacing: DesignTokens.Spacing.md) {
                        Button("Default") {}
                            .buttonStyle(.secondary)

                        Button("Custom") {}
                            .buttonStyle(.secondary(color: .green))
                    }
                }

                Divider()

                // Other styles
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Other Styles")
                        .font(DesignTokens.Typography.headline)

                    HStack(spacing: DesignTokens.Spacing.md) {
                        Button("Ghost") {}
                            .buttonStyle(.ghost)

                        Button("Glass") {}
                            .buttonStyle(.stashGlass)

                        Button {} label: {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                        .buttonStyle(.icon(size: 50, backgroundColor: .blue.opacity(0.2)))
                    }
                }

                Divider()

                // Exercise styles
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Exercise Styles")
                        .font(DesignTokens.Typography.headline)

                    HStack(spacing: DesignTokens.Spacing.md) {
                        Button("Delete") {}
                            .buttonStyle(.destructive)

                        Button("Save") {}
                            .buttonStyle(.loading(isLoading: false))

                        Button("Saving...") {}
                            .buttonStyle(.loading(isLoading: true))
                    }
                }
            }
            .padding()
        }
    }
}
