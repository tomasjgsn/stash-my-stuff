//
//  CategoryModifier.swift
//  StashMyStuff
//
//  Created by Tomas Juergensen on 27/12/2025.
//

import SwiftUI

// MARK: - Category Accent Modifier

struct CategoryAccentModifier: ViewModifier {
    let category: Category

    func body(content: Content) -> some View {
        content
            .tint(self.category.color)
            .foregroundStyle(self.category.color)
    }
}

extension View {
    /// Applies the category's accent color as tint and foreground
    func categoryAccent(_ category: Category) -> some View {
        self.modifier(CategoryAccentModifier(category: category))
    }
}

// MARK: - Category Badge Modifier

struct CategoryBadgeModifier: ViewModifier {
    let category: Category

    func body(content: Content) -> some View {
        content
            .font(DesignTokens.Typography.caption)
            .fontWeight(.medium)
            .padding(.horizontal, DesignTokens.Spacing.xs)
            .padding(.vertical, DesignTokens.Spacing.xxs)
            .background(self.category.color.opacity(0.15))
            .foregroundStyle(self.category.color)
            .clipShape(Capsule())
    }
}

extension View {
    /// Styles content as a category badge pill
    func categoryBadge(_ category: Category) -> some View {
        self.modifier(CategoryBadgeModifier(category: category))
    }
}

// MARK: - Preview

#Preview("Category Modifiers") {
    VStack(spacing: DesignTokens.Spacing.lg) {
        // Category accent on icons
        HStack(spacing: DesignTokens.Spacing.lg) {
            ForEach(Category.allCases.prefix(5), id: \.self) { category in
                Image(systemName: CategoryConfig.config(for: category)?.icon ?? "questionmark")
                    .font(.title)
                    .categoryAccent(category)
            }
        }

        Divider()

        // Category badges
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            ForEach(Category.allCases, id: \.self) { category in
                Text(category.rawValue)
                    .categoryBadge(category)
            }
        }
    }
    .padding()
}
