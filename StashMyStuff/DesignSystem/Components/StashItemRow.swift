//
//  StashItemRow.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Stash Item Row

/// A row displaying a stash item in a list
struct StashItemRow: View {
    let item: StashItem
    let style: RowStyle
    let onFavoriteToggle: (() -> Void)?

    enum RowStyle {
        case compact // Just title and category icon
        case standard // Thumbnail, title, subtitle, flags
        case detailed // Full info with tags
    }

    init(
        item: StashItem,
        style: RowStyle = .standard,
        onFavoriteToggle: (() -> Void)? = nil
    ) {
        self.item = item
        self.style = style
        self.onFavoriteToggle = onFavoriteToggle
    }

    var body: some View {
        switch self.style {
        case .compact:
            self.compactRow
        case .standard:
            self.standardRow
        case .detailed:
            self.detailedRow
        }
    }

    // MARK: - Compact Row

    private var compactRow: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            CategoryIcon(self.item.category, size: .small, style: .circle)

            Text(self.item.title)
                .font(DesignTokens.Typography.body)
                .lineLimit(1)

            Spacer()

            if self.item.isFavorite {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    // MARK: - Standard Row

    private var standardRow: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Thumbnail
            ItemThumbnail(
                url: self.item.imageURL,
                category: self.item.category,
                size: .medium
            )

            // Content
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                // Title
                Text(self.item.title)
                    .font(DesignTokens.Typography.headline)
                    .lineLimit(2)

                // Subtitle (source domain or category)
                if let domain = self.item.sourceDomain {
                    Text(domain)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(self.item.category.rawValue)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(self.item.category.color)
                }

                // Active flags
                if let config = CategoryConfig.config(for: self.item.category) {
                    self.activeFlags(from: config.flags)
                }
            }

            Spacer(minLength: 0)

            // Favorite indicator
            VStack {
                if self.item.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                Spacer()
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    // MARK: - Detailed Row

    private var detailedRow: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            // Standard row content
            self.standardRow

            // Tags (if any)
            if !self.item.tags.isEmpty {
                TagDisplay(
                    self.item.tags.map(\.name),
                    color: self.item.category.color,
                    maxVisible: 4
                )
            }
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func activeFlags(from definitions: [FlagDefinition]) -> some View {
        let activeFlags = definitions.filter { self.item.flags[$0.key] == true }

        if !activeFlags.isEmpty {
            HStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(activeFlags.prefix(3), id: \.key) { flag in
                    HStack(spacing: 2) {
                        Image(systemName: flag.icon)
                            .font(.system(size: 10))
                        Text(flag.label)
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Glass Item Card

/// A card-style item display for grids and featured sections
struct StashItemCard: View {
    let item: StashItem
    let showCategory: Bool

    init(item: StashItem, showCategory: Bool = true) {
        self.item = item
        self.showCategory = showCategory
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            // Image
            ItemThumbnail(
                url: self.item.imageURL,
                category: self.item.category,
                size: .hero
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(1.5, contentMode: .fill)
            .clipped()

            // Content
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                if self.showCategory {
                    Text(self.item.category.rawValue)
                        .categoryBadge(self.item.category)
                }

                Text(self.item.title)
                    .font(DesignTokens.Typography.headline)
                    .lineLimit(2)

                if let domain = self.item.sourceDomain {
                    Text(domain)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.bottom, DesignTokens.Spacing.sm)
        }
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .fill(Color(.secondarySystemBackground))
        }
        .overlay(alignment: .topTrailing) {
            if self.item.isFavorite {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(DesignTokens.Spacing.xs)
                    .background(Circle().fill(.red))
                    .padding(DesignTokens.Spacing.sm)
            }
        }
    }
}

// MARK: - Source Badge

/// Displays the source domain of an item
struct SourceBadge: View {
    let url: URL?

    var domain: String? {
        self.url?.host()?.replacingOccurrences(of: "www.", with: "")
    }

    var body: some View {
        if let domain {
            HStack(spacing: DesignTokens.Spacing.xxs) {
                Image(systemName: "link")
                    .font(.system(size: 10))

                Text(domain)
                    .font(DesignTokens.Typography.caption2)
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, DesignTokens.Spacing.xs)
            .padding(.vertical, 2)
            .background {
                Capsule()
                    .fill(Color(.systemGray6))
            }
        }
    }
}

// MARK: - Empty State View (Exercise 2)

/// An empty state view for when a category has no items
struct EmptyStateView: View {
    let category: Category
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        category: Category,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.category = category
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            CategoryIcon(self.category, size: .extraLarge, style: .circle)

            Text(self.message)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(PrimaryButtonStyle(color: self.category.color))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignTokens.Spacing.xl)
    }
}

// MARK: - Preview Helpers

extension StashItem {
    static var preview: StashItem {
        let item = StashItem(
            title: "Chocolate Chip Cookies",
            category: .recipe,
            sourceURL: URL(string: "https://cooking.nytimes.com/recipes/123")
        )
        return item
    }

    static var previewFavorite: StashItem {
        let item = StashItem(
            title: "The Great Gatsby",
            category: .book,
            sourceURL: URL(string: "https://goodreads.com/book/123")
        )
        item.isFavorite = true
        return item
    }

    static var previewWithFlags: StashItem {
        let item = StashItem(
            title: "Grandma's Lasagna",
            category: .recipe,
            sourceURL: URL(string: "https://allrecipes.com/recipe/123")
        )
        item.flags = ["hasBeenCooked": true, "wouldCookAgain": true]
        return item
    }

    static var previewWithTags: StashItem {
        let item = StashItem(
            title: "Weekend Pancakes",
            category: .recipe,
            sourceURL: nil
        )
        item.flags = ["hasBeenCooked": true]
        return item
    }
}

// MARK: - Previews

#Preview("StashItemRow Styles") {
    List {
        Section("Compact") {
            StashItemRow(item: .preview, style: .compact)
            StashItemRow(item: .previewFavorite, style: .compact)
        }

        Section("Standard") {
            StashItemRow(item: .preview, style: .standard)
            StashItemRow(item: .previewWithFlags, style: .standard)
        }

        Section("Detailed") {
            StashItemRow(item: .previewWithTags, style: .detailed)
        }
    }
}

#Preview("StashItemCard") {
    ScrollView {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: DesignTokens.Spacing.md
        ) {
            StashItemCard(item: .preview)
            StashItemCard(item: .previewFavorite)
            StashItemCard(item: .previewWithFlags)
        }
        .padding()
    }
}

#Preview("SourceBadge") {
    VStack(spacing: DesignTokens.Spacing.md) {
        SourceBadge(url: URL(string: "https://cooking.nytimes.com/recipe/123"))
        SourceBadge(url: URL(string: "https://www.goodreads.com/book/456"))
        SourceBadge(url: URL(string: "https://bandcamp.com/album/789"))
        SourceBadge(url: nil) // Empty
    }
    .padding()
}

#Preview("EmptyStateView") {
    VStack(spacing: DesignTokens.Spacing.xl) {
        EmptyStateView(
            category: .recipe,
            message: "No recipes saved yet",
            actionTitle: "Add Recipe"
        ) {}

        EmptyStateView(
            category: .book,
            message: "Your reading list is empty"
        )
    }
}
