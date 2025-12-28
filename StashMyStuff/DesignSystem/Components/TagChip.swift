//
//  TagChip.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Tag Chip

/// A pill-shaped chip displaying a tag name
struct TagChip: View {
    let name: String
    let color: Color
    let onRemove: (() -> Void)?

    init(
        _ name: String,
        color: Color = .accentColor,
        onRemove: (() -> Void)? = nil
    ) {
        self.name = name
        self.color = color
        self.onRemove = onRemove
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xxs) {
            Text(self.name)
                .font(DesignTokens.Typography.caption)
                .fontWeight(.medium)

            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xxs)
        .foregroundStyle(self.color)
        .background {
            Capsule()
                .fill(self.color.opacity(0.15))
        }
        .overlay {
            Capsule()
                .stroke(self.color.opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - Auto-Colored Tag Chip (Exercise 1)

extension TagChip {
    /// Creates a tag chip with automatic color based on tag name hash
    init(autoColored name: String, onRemove: (() -> Void)? = nil) {
        let colors: [Color] = [.blue, .purple, .pink, .orange, .green, .teal, .indigo]
        let index = abs(name.hashValue) % colors.count
        self.init(name, color: colors[index], onRemove: onRemove)
    }
}

// MARK: - Preview

#Preview("TagChip") {
    VStack(spacing: DesignTokens.Spacing.lg) {
        // Basic chips
        HStack {
            TagChip("vegetarian")
            TagChip("quick", color: .green)
            TagChip("favorite", color: .orange)
        }

        // With remove button
        HStack {
            TagChip("removable", onRemove: {})
            TagChip("another", color: .purple, onRemove: {})
        }

        // Different colors
        HStack {
            ForEach(Category.allCases.prefix(5), id: \.self) { category in
                TagChip(category.rawValue, color: category.color)
            }
        }

        Divider()

        // Auto-colored (Exercise 1)
        Text("Auto-Colored Tags")
            .font(DesignTokens.Typography.caption)
            .foregroundStyle(.secondary)

        HStack {
            TagChip(autoColored: "breakfast")
            TagChip(autoColored: "vegetarian")
            TagChip(autoColored: "quick")
            TagChip(autoColored: "healthy")
        }
    }
    .padding()
}
