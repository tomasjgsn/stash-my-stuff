//
//  CategoryCard.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Category Card

/// A card displaying a category with its icon and item count
struct CategoryCard: View {
    let category: Category
    let itemCount: Int
    let style: CardStyle

    enum CardStyle {
        case grid // Square card for grids
        case list // Horizontal row for lists
        case compact // Minimal for sidebars
    }

    init(_ category: Category, itemCount: Int, style: CardStyle = .grid) {
        self.category = category
        self.itemCount = itemCount
        self.style = style
    }

    var body: some View {
        switch self.style {
        case .grid:
            self.gridCard
        case .list:
            self.listCard
        case .compact:
            self.compactCard
        }
    }

    // MARK: - Grid Card

    private var gridCard: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            CategoryIcon(self.category, size: .large, style: .circle)

            VStack(spacing: DesignTokens.Spacing.xxs) {
                Text(self.category.rawValue)
                    .font(DesignTokens.Typography.headline)
                    .lineLimit(1)

                Text(self.countText)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignTokens.Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .fill(self.category.color.opacity(0.1))
        }
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .stroke(self.category.color.opacity(0.2), lineWidth: 1)
        }
    }

    // MARK: - List Card

    private var listCard: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            CategoryIcon(self.category, size: .medium, style: .filled)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(self.category.rawValue)
                    .font(DesignTokens.Typography.headline)

                Text(self.countText)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(DesignTokens.Spacing.md)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .fill(Color(.secondarySystemBackground))
        }
    }

    // MARK: - Compact Card

    private var compactCard: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            CategoryIcon(self.category, size: .small, style: .plain)

            Text(self.category.rawValue)
                .font(DesignTokens.Typography.body)

            Spacer()

            Text("\(self.itemCount)")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, DesignTokens.Spacing.xs)
                .padding(.vertical, 2)
                .background {
                    Capsule()
                        .fill(Color(.systemGray5))
                }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    private var countText: String {
        self.itemCount == 1 ? "1 item" : "\(self.itemCount) items"
    }
}

// MARK: - Smart View Row

/// A row for smart view navigation items
struct SmartViewRow: View {
    let title: String
    let icon: String
    let color: Color
    let count: Int
    let description: String?

    init(
        title: String,
        icon: String,
        color: Color = .accentColor,
        count: Int,
        description: String? = nil
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.count = count
        self.description = description
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Icon
            Image(systemName: self.icon)
                .font(.title3)
                .foregroundStyle(self.color)
                .frame(width: 32)

            // Content
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(self.title)
                    .font(DesignTokens.Typography.headline)

                if let description {
                    Text(description)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Count badge
            Text("\(self.count)")
                .font(DesignTokens.Typography.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xxs)
                .background {
                    Capsule()
                        .fill(self.color)
                }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(DesignTokens.Spacing.md)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .fill(self.color.opacity(0.1))
        }
    }
}

// MARK: - Previews

#Preview("CategoryCard Styles") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.xl) {
            // Grid style
            Text("Grid Style")
                .font(DesignTokens.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: DesignTokens.Spacing.md
            ) {
                ForEach(Category.allCases.prefix(6), id: \.self) { category in
                    CategoryCard(category, itemCount: Int.random(in: 0 ... 25), style: .grid)
                }
            }

            Divider()

            // List style
            Text("List Style")
                .font(DesignTokens.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(Category.allCases.prefix(4), id: \.self) { category in
                    CategoryCard(category, itemCount: Int.random(in: 0 ... 25), style: .list)
                }
            }

            Divider()

            // Compact style
            Text("Compact Style (Sidebar)")
                .font(DesignTokens.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                ForEach(Category.allCases, id: \.self) { category in
                    CategoryCard(category, itemCount: Int.random(in: 0 ... 25), style: .compact)
                    if category != Category.allCases.last {
                        Divider()
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(Color(.secondarySystemBackground))
            }
        }
        .padding()
    }
}

#Preview("SmartViewRow") {
    VStack(spacing: DesignTokens.Spacing.md) {
        SmartViewRow(
            title: "Uncooked Recipes",
            icon: "flame",
            color: .orange,
            count: 12,
            description: "Recipes you haven't tried yet"
        )

        SmartViewRow(
            title: "Bandcamp Queue",
            icon: "cart",
            color: .pink,
            count: 5,
            description: "Music to buy on Bandcamp Friday"
        )

        SmartViewRow(
            title: "To Read",
            icon: "book",
            color: .indigo,
            count: 8
        )

        SmartViewRow(
            title: "Favorites",
            icon: "heart.fill",
            color: .red,
            count: 23
        )
    }
    .padding()
}
