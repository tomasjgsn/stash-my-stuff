//
//  CategoryIcon.swift
//  StashMyStuff
//
//  Created by Tomas Juergensen on 27/12/2025.
//

import SwiftUI

/// Displays a category's SF Symbol with proper styling
struct CategoryIcon: View {
    let category: Category
    let size: IconSize
    let style: IconStyle

    enum IconSize {
        case small // 20pt - for list items
        case medium // 28pt - for cards
        case large // 44pt - for headers
        case extraLarge // 60pt - for empty states

        var font: Font {
            switch self {
            case .small: .system(size: 20)
            case .medium: .system(size: 28)
            case .large: .system(size: 44)
            case .extraLarge: .system(size: 60)
            }
        }

        var frameSize: CGFloat {
            switch self {
            case .small: 32
            case .medium: 44
            case .large: 64
            case .extraLarge: 88
            }
        }
    }

    enum IconStyle {
        case plain // Just the icon
        case circle // In a circle background
        case filled // In a filled circle
    }

    init(
        _ category: Category,
        size: IconSize = .medium,
        style: IconStyle = .plain
    ) {
        self.category = category
        self.size = size
        self.style = style
    }

    var body: some View {
        let config = CategoryConfig.config(for: self.category)
        let symbolName = config?.icon ?? "questionmark"

        Group {
            switch self.style {
            case .plain:
                Image(systemName: symbolName)
                    .font(self.size.font)
                    .foregroundStyle(self.category.color)

            case .circle:
                Image(systemName: symbolName)
                    .font(self.size.font)
                    .foregroundStyle(self.category.color)
                    .frame(width: self.size.frameSize, height: self.size.frameSize)
                    .background {
                        Circle()
                            .fill(self.category.color.opacity(0.15))
                    }

            case .filled:
                Image(systemName: symbolName)
                    .font(self.size.font)
                    .foregroundStyle(.white)
                    .frame(width: self.size.frameSize, height: self.size.frameSize)
                    .background {
                        Circle()
                            .fill(self.category.color)
                    }
            }
        }
        .accessibilityLabel(self.category.rawValue)
    }
}

// MARK: - Preview

#Preview("CategoryIcon Sizes") {
    VStack(spacing: DesignTokens.Spacing.xl) {
        // All sizes for one category
        HStack(spacing: DesignTokens.Spacing.lg) {
            CategoryIcon(.recipe, size: .small)
            CategoryIcon(.recipe, size: .medium)
            CategoryIcon(.recipe, size: .large)
            CategoryIcon(.recipe, size: .extraLarge)
        }

        Divider()

        // All categories at medium size
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: DesignTokens.Spacing.md) {
            ForEach(Category.allCases, id: \.self) { category in
                VStack {
                    CategoryIcon(category, size: .medium)
                    Text(category.rawValue)
                        .font(DesignTokens.Typography.caption2)
                        .lineLimit(1)
                }
            }
        }
    }
    .padding()
}

#Preview("CategoryIcon Styles") {
    VStack(spacing: DesignTokens.Spacing.xl) {
        HStack(spacing: DesignTokens.Spacing.xl) {
            VStack {
                CategoryIcon(.book, size: .large, style: .plain)
                Text("Plain")
                    .font(.caption)
            }

            VStack {
                CategoryIcon(.book, size: .large, style: .circle)
                Text("Circle")
                    .font(.caption)
            }

            VStack {
                CategoryIcon(.book, size: .large, style: .filled)
                Text("Filled")
                    .font(.caption)
            }
        }

        Divider()

        // All categories with circle style
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: DesignTokens.Spacing.md) {
            ForEach(Category.allCases, id: \.self) { category in
                CategoryIcon(category, size: .medium, style: .circle)
            }
        }
    }
    .padding()
}

// MARK: - Interactive Category Icon

struct InteractiveCategoryIcon: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    @State
    private var isPressed = false

    var body: some View {
        Button(action: self.action) {
            CategoryIcon(
                self.category,
                size: .medium,
                style: self.isSelected ? .filled : .circle
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(self.isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: self.isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: self.isSelected)
        .onLongPressGesture(
            minimumDuration: .infinity,
            pressing: { pressing in
                self.isPressed = pressing
            },
            perform: {}
        )
    }
}

#Preview("Interactive Icons") {
    struct PreviewWrapper: View {
        @State
        private var selected: Category? = .recipe

        var body: some View {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: DesignTokens.Spacing.md) {
                ForEach(Category.allCases, id: \.self) { category in
                    InteractiveCategoryIcon(
                        category: category,
                        isSelected: selected == category
                    ) {
                        selected = category
                    }
                }
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

// MARK: - Flag Icon

struct FlagIcon: View {
    let flag: FlagDefinition
    let isActive: Bool
    let size: CGFloat

    init(_ flag: FlagDefinition, isActive: Bool = false, size: CGFloat = 20) {
        self.flag = flag
        self.isActive = isActive
        self.size = size
    }

    var body: some View {
        Image(systemName: self.flag.icon)
            .font(.system(size: self.size))
            .foregroundStyle(self.isActive ? .primary : .secondary)
            .symbolRenderingMode(self.isActive ? .hierarchical : .monochrome)
    }
}

#Preview("Flag Icons") {
    let recipeFlags = CategoryConfig.config(for: .recipe)?.flags ?? []

    VStack(spacing: DesignTokens.Spacing.lg) {
        ForEach(recipeFlags, id: \.key) { flag in
            HStack {
                FlagIcon(flag, isActive: false)
                FlagIcon(flag, isActive: true)
                Text(flag.label)
            }
        }
    }
    .padding()
}

#Preview("All Category Icons Check") {
    List(Category.allCases, id: \.self) { category in
        HStack {
            CategoryIcon(category, size: .medium, style: .circle)

            VStack(alignment: .leading) {
                Text(category.rawValue)
                    .font(DesignTokens.Typography.headline)

                if let config = CategoryConfig.config(for: category) {
                    Text("Icon: \(config.icon)")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Show flags count
            if let config = CategoryConfig.config(for: category) {
                Text("\(config.flags.count) flags")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Source Icon (Exercise 1)

/// Displays a favicon for a URL's domain
struct SourceIcon: View {
    let url: URL
    let size: CGFloat

    init(url: URL, size: CGFloat = 20) {
        self.url = url
        self.size = size
    }

    var faviconURL: URL? {
        guard let host = url.host() else { return nil }
        return URL(string: "https://www.google.com/s2/favicons?domain=\(host)&sz=64")
    }

    var body: some View {
        AsyncImage(url: self.faviconURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: self.size, height: self.size)
            case let .success(image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: "globe")
                    .font(.system(size: self.size * 0.8))
                    .foregroundStyle(.secondary)
            @unknown default:
                Image(systemName: "globe")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: self.size, height: self.size)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

#Preview("Source Icons") {
    VStack(spacing: DesignTokens.Spacing.lg) {
        HStack(spacing: DesignTokens.Spacing.md) {
            if let url = URL(string: "https://nytcooking.com") {
                SourceIcon(url: url, size: 32)
                Text("NY Times Cooking")
            }
        }

        HStack(spacing: DesignTokens.Spacing.md) {
            if let url = URL(string: "https://github.com") {
                SourceIcon(url: url, size: 32)
                Text("GitHub")
            }
        }

        HStack(spacing: DesignTokens.Spacing.md) {
            if let url = URL(string: "https://bandcamp.com") {
                SourceIcon(url: url, size: 32)
                Text("Bandcamp")
            }
        }

        HStack(spacing: DesignTokens.Spacing.md) {
            if let url = URL(string: "https://invalid-domain-xyz.fake") {
                SourceIcon(url: url, size: 32)
                Text("Invalid (fallback)")
            }
        }
    }
    .padding()
}

// MARK: - Badge Icon (Exercise 2)

/// An icon with a notification-style badge that bounces when the count changes
struct BadgeIcon: View {
    let systemName: String
    let badgeCount: Int
    let iconSize: CGFloat
    let badgeColor: Color

    @State
    private var bounceValue = 0

    init(
        systemName: String,
        badgeCount: Int,
        iconSize: CGFloat = 24,
        badgeColor: Color = .red
    ) {
        self.systemName = systemName
        self.badgeCount = badgeCount
        self.iconSize = iconSize
        self.badgeColor = badgeColor
    }

    var body: some View {
        Image(systemName: self.systemName)
            .font(.system(size: self.iconSize))
            .overlay(alignment: .topTrailing) {
                if self.badgeCount > 0 {
                    Text(self.badgeCount > 99 ? "99+" : "\(self.badgeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(self.badgeColor)
                        .clipShape(Capsule())
                        .offset(x: 8, y: -8)
                        .symbolEffect(.bounce, value: self.bounceValue)
                }
            }
            .onChange(of: self.badgeCount) { _, _ in
                self.bounceValue += 1
            }
    }
}

#Preview("Badge Icons") {
    struct BadgePreview: View {
        @State
        private var count = 3

        var body: some View {
            VStack(spacing: DesignTokens.Spacing.xl) {
                HStack(spacing: DesignTokens.Spacing.xl) {
                    BadgeIcon(systemName: "bell", badgeCount: count)
                    BadgeIcon(systemName: "envelope", badgeCount: 12)
                    BadgeIcon(systemName: "cart", badgeCount: 99)
                    BadgeIcon(systemName: "heart", badgeCount: 150, badgeColor: .pink)
                }

                Divider()

                HStack {
                    Button("Add") { count += 1 }
                    Button("Reset") { count = 0 }
                }
                .buttonStyle(.bordered)

                Text("Tap 'Add' to see bounce animation")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return BadgePreview()
}
