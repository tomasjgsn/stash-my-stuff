//
//  FlagButton.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Flag Button

/// A toggleable button for item flags (cooked, read, watched, etc.)
struct FlagButton: View {
    let flag: FlagDefinition
    @Binding
    var isActive: Bool
    let onToggle: (() -> Void)?

    @State
    private var isAnimating = false

    init(
        flag: FlagDefinition,
        isActive: Binding<Bool>,
        onToggle: (() -> Void)? = nil
    ) {
        self.flag = flag
        self._isActive = isActive
        self.onToggle = onToggle
    }

    var body: some View {
        Button {
            // Trigger animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                self.isActive.toggle()
                self.isAnimating = true
            }

            // Reset animation state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isAnimating = false
            }

            self.onToggle?()
        } label: {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Image(systemName: self.isActive ? self.flag.icon : self.inactiveIcon)
                    .font(.system(size: 16, weight: .medium))
                    .symbolEffect(.bounce, value: self.isAnimating)

                Text(self.flag.label)
                    .font(DesignTokens.Typography.subheadline)
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .foregroundStyle(self.isActive ? .white : .primary)
            .background {
                Capsule()
                    .fill(self.isActive ? Color.accentColor : Color(.systemGray5))
            }
        }
        .buttonStyle(.plain)
    }

    /// Gets an outline version of the icon if available
    private var inactiveIcon: String {
        let filled = self.flag.icon
        if filled.hasSuffix(".fill") {
            return String(filled.dropLast(5))
        }
        return filled
    }
}

// MARK: - Compact Flag Button

/// A smaller, icon-only flag toggle
struct CompactFlagButton: View {
    let flag: FlagDefinition
    @Binding
    var isActive: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                self.isActive.toggle()
            }
        } label: {
            Image(systemName: self.isActive ? self.flag.icon : self.inactiveIcon)
                .font(.system(size: 18))
                .foregroundStyle(self.isActive ? Color.accentColor : .secondary)
                .frame(width: 36, height: 36)
                .background {
                    Circle()
                        .fill(self.isActive ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(self.flag.label)
        .accessibilityAddTraits(self.isActive ? .isSelected : [])
    }

    private var inactiveIcon: String {
        let filled = self.flag.icon
        if filled.hasSuffix(".fill") {
            return String(filled.dropLast(5))
        }
        return filled
    }
}

// MARK: - Flag Row

/// A full-width toggle row for editing screens
struct FlagRow: View {
    let flag: FlagDefinition
    @Binding
    var isActive: Bool

    var body: some View {
        Toggle(isOn: self.$isActive) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: self.flag.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(self.isActive ? Color.accentColor : .secondary)
                    .frame(width: 24)

                Text(self.flag.label)
                    .font(DesignTokens.Typography.body)
            }
        }
        .toggleStyle(.switch)
    }
}

// MARK: - Previews

#Preview("FlagButton") {
    struct PreviewWrapper: View {
        @State
        private var cooked = false
        @State
        private var wouldCookAgain = true
        @State
        private var inBook = false

        var body: some View {
            let flags = CategoryConfig.config(for: .recipe)?.flags ?? []

            VStack(spacing: DesignTokens.Spacing.lg) {
                Text("Recipe Flags")
                    .font(DesignTokens.Typography.headline)

                if flags.count >= 3 {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        FlagButton(flag: flags[0], isActive: $cooked)
                        FlagButton(flag: flags[1], isActive: $wouldCookAgain)
                        FlagButton(flag: flags[2], isActive: $inBook)
                    }
                }

                Divider()

                // Show all category flags
                ForEach(Category.allCases.prefix(3), id: \.self) { category in
                    if let config = CategoryConfig.config(for: category) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                            Text(category.rawValue)
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(.secondary)

                            FlowLayout(spacing: DesignTokens.Spacing.xs) {
                                ForEach(config.flags, id: \.key) { flag in
                                    FlagButtonPreview(flag: flag)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

// Helper for previews
private struct FlagButtonPreview: View {
    let flag: FlagDefinition
    @State
    private var isActive = false

    var body: some View {
        FlagButton(flag: self.flag, isActive: self.$isActive)
    }
}

#Preview("Compact Flag Buttons") {
    struct PreviewWrapper: View {
        @State
        private var flags: [String: Bool] = [:]

        var body: some View {
            if let config = CategoryConfig.config(for: .movie) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(config.flags, id: \.key) { flag in
                        CompactFlagButton(
                            flag: flag,
                            isActive: Binding(
                                get: { flags[flag.key] ?? false },
                                set: { flags[flag.key] = $0 }
                            )
                        )
                    }
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Flag Row") {
    struct PreviewWrapper: View {
        @State
        private var flags: [String: Bool] = [:]

        var body: some View {
            Form {
                if let config = CategoryConfig.config(for: .book) {
                    Section("Book Flags") {
                        ForEach(config.flags, id: \.key) { flag in
                            FlagRow(
                                flag: flag,
                                isActive: Binding(
                                    get: { flags[flag.key] ?? false },
                                    set: { flags[flag.key] = $0 }
                                )
                            )
                        }
                    }
                }
            }
        }
    }

    return PreviewWrapper()
}
