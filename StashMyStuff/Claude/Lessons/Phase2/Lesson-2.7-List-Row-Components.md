# Lesson 2.7: List Row Components

> **Type**: Standard lesson (25-30 min)
> **Concepts**: NEW - AsyncImage, contextShape, swipe actions, List styling
> **Builds**: `DesignSystem/Components/StashItemRow.swift`, `DesignSystem/Components/CategoryCard.swift`

---

## What You'll Learn

Lists are the backbone of most apps. In this lesson, you'll build the row components that display stash items and categories - the views users will interact with most.

---

## Prerequisites

Complete **Lessons 2.1-2.6** - you'll use all previously built components.

---

## Part 1: Understanding AsyncImage

Before building rows, let's understand how to load images from URLs:

### NEW: AsyncImage

`AsyncImage` loads images asynchronously from a URL:

```swift
// Basic usage
AsyncImage(url: URL(string: "https://example.com/image.jpg"))

// With placeholder
AsyncImage(url: imageURL) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    ProgressView()
}

// Full control with phases
AsyncImage(url: imageURL) { phase in
    switch phase {
    case .empty:
        ProgressView()
    case .success(let image):
        image.resizable().aspectRatio(contentMode: .fill)
    case .failure:
        Image(systemName: "photo")
            .foregroundStyle(.secondary)
    @unknown default:
        EmptyView()
    }
}
```

---

## Part 2: Item Thumbnail Component

Let's create a reusable thumbnail that handles loading states:

**File**: `StashMyStuff/DesignSystem/Components/ItemThumbnail.swift`

```swift
//
//  ItemThumbnail.swift
//  StashMyStuff
//

import SwiftUI

/// Displays an item's thumbnail image with loading and error states
struct ItemThumbnail: View {
    let url: URL?
    let category: Category
    let size: ThumbnailSize

    enum ThumbnailSize {
        case small   // 44pt - for compact lists
        case medium  // 60pt - for standard lists
        case large   // 80pt - for featured items
        case hero    // 120pt - for detail headers

        var dimension: CGFloat {
            switch self {
            case .small: return 44
            case .medium: return 60
            case .large: return 80
            case .hero: return 120
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: return DesignTokens.Radius.sm
            case .medium: return DesignTokens.Radius.md
            case .large: return DesignTokens.Radius.lg
            case .hero: return DesignTokens.Radius.xl
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 24
            case .large: return 32
            case .hero: return 44
            }
        }
    }

    init(url: URL?, category: Category, size: ThumbnailSize = .medium) {
        self.url = url
        self.category = category
        self.size = size
    }

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderView
                            .overlay {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderView
                    @unknown default:
                        placeholderView
                    }
                }
            } else {
                placeholderView
            }
        }
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
    }

    private var placeholderView: some View {
        ZStack {
            category.color.opacity(0.15)

            if let config = CategoryConfig.config(for: category) {
                Image(systemName: config.icon)
                    .font(.system(size: size.iconSize))
                    .foregroundStyle(category.color)
            }
        }
    }
}

// MARK: - Preview
#Preview("ItemThumbnail") {
    VStack(spacing: DesignTokens.Spacing.lg) {
        // With image URL
        HStack(spacing: DesignTokens.Spacing.md) {
            ItemThumbnail(
                url: URL(string: "https://picsum.photos/200"),
                category: .recipe,
                size: .small
            )
            ItemThumbnail(
                url: URL(string: "https://picsum.photos/200"),
                category: .recipe,
                size: .medium
            )
            ItemThumbnail(
                url: URL(string: "https://picsum.photos/200"),
                category: .recipe,
                size: .large
            )
        }

        Divider()

        // Placeholders (no URL)
        HStack(spacing: DesignTokens.Spacing.md) {
            ForEach(Category.allCases.prefix(5), id: \.self) { category in
                ItemThumbnail(url: nil, category: category, size: .medium)
            }
        }

        Divider()

        // Hero size
        ItemThumbnail(url: nil, category: .book, size: .hero)
    }
    .padding()
}
```

---

## Part 3: The StashItemRow Component

Now let's build the main item row:

**File**: `StashMyStuff/DesignSystem/Components/StashItemRow.swift`

```swift
//
//  StashItemRow.swift
//  StashMyStuff
//

import SwiftUI

/// A row displaying a stash item in a list
struct StashItemRow: View {
    let item: StashItem
    let style: RowStyle
    let onFavoriteToggle: (() -> Void)?

    enum RowStyle {
        case compact   // Just title and category icon
        case standard  // Thumbnail, title, subtitle, flags
        case detailed  // Full info with tags
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
        switch style {
        case .compact:
            compactRow
        case .standard:
            standardRow
        case .detailed:
            detailedRow
        }
    }

    // MARK: - Compact Row
    private var compactRow: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            CategoryIcon(item.category, size: .small, style: .circle)

            Text(item.title)
                .font(DesignTokens.Typography.body)
                .lineLimit(1)

            Spacer()

            if item.isFavorite {
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
                url: item.imageURL,
                category: item.category,
                size: .medium
            )

            // Content
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                // Title
                Text(item.title)
                    .font(DesignTokens.Typography.headline)
                    .lineLimit(2)

                // Subtitle (source domain or category)
                if let domain = item.sourceDomain {
                    Text(domain)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(item.category.rawValue)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(item.category.color)
                }

                // Active flags
                if let config = CategoryConfig.config(for: item.category) {
                    activeFlags(from: config.flags)
                }
            }

            Spacer(minLength: 0)

            // Favorite indicator
            VStack {
                if item.isFavorite {
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
            standardRow

            // Tags (if any)
            if !item.tags.isEmpty {
                TagDisplay(
                    item.tags.map(\.name),
                    color: item.category.color,
                    maxVisible: 4
                )
            }
        }
    }

    // MARK: - Helpers
    @ViewBuilder
    private func activeFlags(from definitions: [FlagDefinition]) -> some View {
        let activeFlags = definitions.filter { item.flags[$0.key] == true }

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

// MARK: - Preview
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
        // Note: Tags would need to be actual Tag objects in real use
        return item
    }
}
```

---

## Part 4: Glass Card Row Variant

For home screens with a more visual presentation:

```swift
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
                url: item.imageURL,
                category: item.category,
                size: .hero
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(1.5, contentMode: .fill)
            .clipped()

            // Content
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                if showCategory {
                    Text(item.category.rawValue)
                        .categoryBadge(item.category)
                }

                Text(item.title)
                    .font(DesignTokens.Typography.headline)
                    .lineLimit(2)

                if let domain = item.sourceDomain {
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
            if item.isFavorite {
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

#Preview("StashItemCard") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignTokens.Spacing.md) {
            StashItemCard(item: .preview)
            StashItemCard(item: .previewFavorite)
            StashItemCard(item: .previewWithFlags)
        }
        .padding()
    }
}
```

---

## Part 5: CategoryCard Component

For the home screen category grid:

**File**: `StashMyStuff/DesignSystem/Components/CategoryCard.swift`

```swift
//
//  CategoryCard.swift
//  StashMyStuff
//

import SwiftUI

/// A card displaying a category with its icon and item count
struct CategoryCard: View {
    let category: Category
    let itemCount: Int
    let style: CardStyle

    enum CardStyle {
        case grid      // Square card for grids
        case list      // Horizontal row for lists
        case compact   // Minimal for sidebars
    }

    init(_ category: Category, itemCount: Int, style: CardStyle = .grid) {
        self.category = category
        self.itemCount = itemCount
        self.style = style
    }

    var body: some View {
        switch style {
        case .grid:
            gridCard
        case .list:
            listCard
        case .compact:
            compactCard
        }
    }

    // MARK: - Grid Card
    private var gridCard: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            CategoryIcon(category, size: .large, style: .circle)

            VStack(spacing: DesignTokens.Spacing.xxs) {
                Text(category.rawValue)
                    .font(DesignTokens.Typography.headline)
                    .lineLimit(1)

                Text(countText)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignTokens.Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .fill(category.color.opacity(0.1))
        }
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .stroke(category.color.opacity(0.2), lineWidth: 1)
        }
    }

    // MARK: - List Card
    private var listCard: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            CategoryIcon(category, size: .medium, style: .filled)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(category.rawValue)
                    .font(DesignTokens.Typography.headline)

                Text(countText)
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
            CategoryIcon(category, size: .small, style: .plain)

            Text(category.rawValue)
                .font(DesignTokens.Typography.body)

            Spacer()

            Text("\(itemCount)")
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
        itemCount == 1 ? "1 item" : "\(itemCount) items"
    }
}

// MARK: - Preview
#Preview("CategoryCard Styles") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.xl) {
            // Grid style
            Text("Grid Style")
                .font(DesignTokens.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignTokens.Spacing.md) {
                ForEach(Category.allCases.prefix(6), id: \.self) { category in
                    CategoryCard(category, itemCount: Int.random(in: 0...25), style: .grid)
                }
            }

            Divider()

            // List style
            Text("List Style")
                .font(DesignTokens.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(Category.allCases.prefix(4), id: \.self) { category in
                    CategoryCard(category, itemCount: Int.random(in: 0...25), style: .list)
                }
            }

            Divider()

            // Compact style
            Text("Compact Style (Sidebar)")
                .font(DesignTokens.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 0) {
                ForEach(Category.allCases, id: \.self) { category in
                    CategoryCard(category, itemCount: Int.random(in: 0...25), style: .compact)
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
```

---

## Part 6: Smart View Row

For the "Smart Views" section (Uncooked Recipes, Bandcamp Queue, etc.):

```swift
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
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)

            // Content
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(title)
                    .font(DesignTokens.Typography.headline)

                if let description {
                    Text(description)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Count badge
            Text("\(count)")
                .font(DesignTokens.Typography.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xxs)
                .background {
                    Capsule()
                        .fill(color)
                }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(DesignTokens.Spacing.md)
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .fill(color.opacity(0.1))
        }
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
```

---

## Part 7: Source Badge Component

A small component showing the source domain:

```swift
// MARK: - Source Badge
/// Displays the source domain of an item
struct SourceBadge: View {
    let url: URL?

    var domain: String? {
        url?.host()?.replacingOccurrences(of: "www.", with: "")
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

#Preview("SourceBadge") {
    VStack(spacing: DesignTokens.Spacing.md) {
        SourceBadge(url: URL(string: "https://cooking.nytimes.com/recipe/123"))
        SourceBadge(url: URL(string: "https://www.goodreads.com/book/456"))
        SourceBadge(url: URL(string: "https://bandcamp.com/album/789"))
        SourceBadge(url: nil)  // Empty
    }
    .padding()
}
```

---

## Exercise: Your Turn

### Exercise 1: Add Swipe Actions

Modify `StashItemRow` to support swipe-to-delete and swipe-to-favorite when used in a List:

<details>
<summary>Hint</summary>

Use `.swipeActions(edge:)` modifier in the parent List, not in the row itself.

</details>

<details>
<summary>Solution</summary>

```swift
// In the parent view using the rows:
List {
    ForEach(items) { item in
        StashItemRow(item: item)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    deleteItem(item)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .swipeActions(edge: .leading) {
                Button {
                    toggleFavorite(item)
                } label: {
                    Label(
                        item.isFavorite ? "Unfavorite" : "Favorite",
                        systemImage: item.isFavorite ? "heart.slash" : "heart"
                    )
                }
                .tint(.pink)
            }
    }
}
```

</details>

### Exercise 2: Empty State Component

Create an `EmptyStateView` for when a category has no items:

```swift
EmptyStateView(
    category: .recipe,
    message: "No recipes saved yet",
    actionTitle: "Add Recipe"
) {
    // Add action
}
```

---

## What You Built

List components in `DesignSystem/Components/`:

- **ItemThumbnail.swift** - Async image loading with placeholders
- **StashItemRow.swift** - Compact, standard, and detailed row styles
- **StashItemCard.swift** - Card variant for grids
- **CategoryCard.swift** - Grid, list, and compact category displays
- **SmartViewRow.swift** - Navigation rows for smart views
- **SourceBadge.swift** - Domain display badge

---

## Key Concepts Learned

| Concept | What You Learned |
|---------|------------------|
| `AsyncImage` | Loading remote images with phases |
| Row styles | Different layouts for different contexts |
| Grid vs List | When to use cards vs rows |
| Preview helpers | Static properties for testing |
| Component composition | Building complex UI from simple parts |

---

## Next Lesson

In **Lesson 2.8: Animations and Haptics**, you'll add life to these components with spring animations, transitions, and tactile feedback.

---

## Questions for Claude

When working through this lesson, you can ask:
- "How do I cache AsyncImage results?"
- "What's the difference between .fill and .fit for images?"
- "How do I add a context menu to a row?"
- "Can you explain contentShape for hit testing?"

Reference this lesson as: **"Lesson 2.7 - List Rows"**
