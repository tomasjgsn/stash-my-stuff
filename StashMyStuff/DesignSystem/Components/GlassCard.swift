//
//  GlassCard.swift
//  StashMyStuff
//
//  Created by Tomas Juergensen on 27/12/2025.
//

import SwiftUI

/// A Liquid Glass card container with optional header and footer
struct GlassCard<Header: View, Content: View, Footer: View>: View {
    let header: Header?
    let content: Content
    let footer: Footer?
    let cornerRadius: CGFloat
    let isInteractive: Bool
    let spacing: CGFloat

    /// Initialize with content only
    init(
        cornerRadius: CGFloat = DesignTokens.Glass.cardRadius,
        isInteractive: Bool = false,
        spacing: CGFloat = DesignTokens.Spacing.md,
        @ViewBuilder content: () -> Content
    ) where Header == EmptyView, Footer == EmptyView {
        self.header = nil
        self.content = content()
        self.footer = nil
        self.cornerRadius = cornerRadius
        self.isInteractive = isInteractive
        self.spacing = spacing
    }

    /// Initialize with header and content
    init(
        cornerRadius: CGFloat = DesignTokens.Glass.cardRadius,
        isInteractive: Bool = false,
        spacing: CGFloat = DesignTokens.Spacing.md,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) where Footer == EmptyView {
        self.header = header()
        self.content = content()
        self.footer = nil
        self.cornerRadius = cornerRadius
        self.isInteractive = isInteractive
        self.spacing = spacing
    }

    /// Initialize with header, content, and footer
    init(
        cornerRadius: CGFloat = DesignTokens.Glass.cardRadius,
        isInteractive: Bool = false,
        spacing: CGFloat = DesignTokens.Spacing.md,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.header = header()
        self.content = content()
        self.footer = footer()
        self.cornerRadius = cornerRadius
        self.isInteractive = isInteractive
        self.spacing = spacing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: self.spacing) {
            if let header {
                header
            }

            self.content

            if let footer {
                footer
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.lg)
        .glassEffect(
            self.isInteractive ? .regular.interactive() : .regular,
            in: .rect(cornerRadius: self.cornerRadius)
        )
    }
}

// MARK: - Preset Styles

extension GlassCard where Header == EmptyView, Footer == EmptyView {
    /// A card optimized for list items (smaller corners)
    static func listItem(
        @ViewBuilder content: () -> Content
    ) -> GlassCard {
        GlassCard(
            cornerRadius: DesignTokens.Glass.chipRadius,
            isInteractive: true, // List items are usually tappable
            spacing: DesignTokens.Spacing.sm,
            content: content
        )
    }

    /// A card optimized for featured/hero content
    static func featured(
        @ViewBuilder content: () -> Content
    ) -> GlassCard {
        GlassCard(
            cornerRadius: DesignTokens.Radius.xl,
            isInteractive: false,
            spacing: DesignTokens.Spacing.lg,
            content: content
        )
    }
}

// MARK: - Category Glass Card

struct CategoryGlassCard<Content: View>: View {
    let category: Category
    let isInteractive: Bool
    let content: Content

    init(
        category: Category,
        isInteractive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.category = category
        self.isInteractive = isInteractive
        self.content = content()
    }

    var body: some View {
        self.content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Spacing.lg)
            .glassEffect(
                // Use Apple's official .tint() API for colored glass
                self.isInteractive
                    ? .regular.tint(self.category.color).interactive()
                    : .regular.tint(self.category.color),
                in: .rect(cornerRadius: DesignTokens.Glass.cardRadius)
            )
    }
}

// MARK: - Expandable Glass Card (Exercise 1)

/// A glass card that expands to show additional content when tapped
struct ExpandableGlassCard<Preview: View, Expanded: View>: View {
    @Binding
    var isExpanded: Bool
    let preview: Preview
    let expanded: Expanded

    init(
        isExpanded: Binding<Bool>,
        @ViewBuilder preview: () -> Preview,
        @ViewBuilder expanded: () -> Expanded
    ) {
        self._isExpanded = isExpanded
        self.preview = preview()
        self.expanded = expanded()
    }

    var body: some View {
        GlassCard(isInteractive: true) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                // Preview is always shown
                HStack {
                    self.preview
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(self.isExpanded ? 180 : 0))
                }

                // Expanded content with animation
                if self.isExpanded {
                    Divider()
                    self.expanded
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                self.isExpanded.toggle()
            }
        }
    }
}

// MARK: - Icon Badge Modifier (Exercise 2)

/// Adds a small icon badge to the top-right corner of a view
struct IconBadgeModifier: ViewModifier {
    let icon: String
    let color: Color
    let isVisible: Bool

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if self.isVisible {
                    Image(systemName: self.icon)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.white)
                        .padding(DesignTokens.Spacing.xs)
                        .background(self.color)
                        .clipShape(Circle())
                        .offset(x: 8, y: -8)
                        .transition(.scale.combined(with: .opacity))
                }
            }
    }
}

extension View {
    /// Adds a customizable icon badge to the top-right corner
    func iconBadge(
        _ icon: String,
        color: Color = .blue,
        isVisible: Bool = true
    ) -> some View {
        self.modifier(IconBadgeModifier(
            icon: icon,
            color: color,
            isVisible: isVisible
        ))
    }
}

// MARK: - Glass Card with Badge

/// A glass card with an optional icon badge
struct BadgedGlassCard<Content: View>: View {
    let badgeIcon: String?
    let badgeColor: Color
    let content: Content

    init(
        badgeIcon: String? = nil,
        badgeColor: Color = .blue,
        @ViewBuilder content: () -> Content
    ) {
        self.badgeIcon = badgeIcon
        self.badgeColor = badgeColor
        self.content = content()
    }

    var body: some View {
        GlassCard {
            self.content
        }
        .iconBadge(
            self.badgeIcon ?? "star.fill",
            color: self.badgeColor,
            isVisible: self.badgeIcon != nil
        )
    }
}

// MARK: - Previews

#Preview("GlassCard Showcase") {
    ZStack {
        LinearGradient(
            colors: [.indigo.opacity(0.3), .purple.opacity(0.3), .pink.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Basic card
                GlassCard {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("Basic Glass Card")
                            .font(DesignTokens.Typography.headline)
                        Text("A simple glass card with just content.")
                            .foregroundStyle(.secondary)
                    }
                }

                // Card with header
                GlassCard {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundStyle(.indigo)
                        Text("Books")
                            .font(DesignTokens.Typography.headline)
                        Spacer()
                        Text("12")
                            .font(DesignTokens.Typography.headline)
                            .foregroundStyle(.secondary)
                    }
                } content: {
                    Text("Your book collection with reading progress tracking.")
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(.secondary)
                }

                // Card with header, content, footer
                GlassCard {
                    Label("Featured Recipe", systemImage: "star.fill")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.orange)
                } content: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text("Chocolate Lava Cake")
                            .font(DesignTokens.Typography.title3)
                        Text("A decadent dessert with a molten chocolate center.")
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    HStack {
                        Label("30 min", systemImage: "clock")
                        Spacer()
                        Label("Easy", systemImage: "chart.bar")
                    }
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.secondary)
                }

                // Preset: List item style
                GlassCard.listItem {
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 20, height: 20)
                        VStack(alignment: .leading) {
                            Text("List Item Style")
                                .font(DesignTokens.Typography.headline)
                            Text("Smaller corners, interactive")
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Badged card
                BadgedGlassCard(badgeIcon: "bell.fill", badgeColor: .red) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("Card with Badge")
                            .font(DesignTokens.Typography.headline)
                        Text("This card has a notification badge.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview("Category Glass Cards") {
    ZStack {
        LinearGradient(
            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                ForEach(Category.allCases.prefix(4), id: \.self) { category in
                    if let config = CategoryConfig.config(for: category) {
                        CategoryGlassCard(category: category, isInteractive: true) {
                            HStack {
                                Image(systemName: config.icon)
                                    .font(.title2)
                                    .foregroundStyle(category.color)

                                VStack(alignment: .leading) {
                                    Text(category.rawValue)
                                        .font(DesignTokens.Typography.headline)
                                    Text("3 items")
                                        .font(DesignTokens.Typography.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview("Expandable Card") {
    struct ExpandablePreview: View {
        @State
        private var isExpanded = false

        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [.teal.opacity(0.3), .blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: DesignTokens.Spacing.lg) {
                    ExpandableGlassCard(isExpanded: $isExpanded) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text("Recipe Details")
                                .font(DesignTokens.Typography.headline)
                            Text("Tap to see ingredients")
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                    } expanded: {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                            Text("Ingredients:")
                                .font(DesignTokens.Typography.subheadline)
                                .fontWeight(.semibold)

                            ForEach(
                                ["2 cups flour", "1 cup sugar", "3 eggs", "1 tsp vanilla"],
                                id: \.self
                            ) { ingredient in
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundStyle(.secondary)
                                    Text(ingredient)
                                        .font(DesignTokens.Typography.body)
                                }
                            }
                        }
                    }

                    Text("isExpanded: \(isExpanded ? "true" : "false")")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
        }
    }

    return ExpandablePreview()
}
