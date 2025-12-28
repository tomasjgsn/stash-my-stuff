# Lesson 2.4: SF Symbols and Icons

> **Type**: Micro-lesson (10-15 min)
> **Concepts**: FAMILIAR - Image views, NEW - SF Symbols, symbol variants, rendering modes
> **Builds**: `DesignSystem/Components/CategoryIcon.swift`

---

## What You'll Learn

SF Symbols is Apple's system icon library with 5,000+ symbols. In this lesson, you'll learn how to use them effectively and build the `CategoryIcon` component for Stash My Stuff.

---

## Part 1: Introduction to SF Symbols

### What are SF Symbols?

SF Symbols are vector icons designed by Apple that:
- Scale automatically with Dynamic Type
- Match the San Francisco font weight
- Support multiple rendering modes
- Work across all Apple platforms
 
**MATLAB/Python analogy**: Think of them like matplotlib's built-in markers (`'o'`, `'s'`, `'^'`), but with thousands of options and much more flexibility.

### Basic Usage

```swift
// Simple symbol
Image(systemName: "star")

// With size (using font)
Image(systemName: "star")
    .font(.title)

// With explicit size
Image(systemName: "star")
    .font(.system(size: 24))

// With color
Image(systemName: "star.fill")
    .foregroundStyle(.yellow)
```

### The SF Symbols App

Download the free SF Symbols app from Apple to browse all available icons:
https://developer.apple.com/sf-symbols/

You can search, preview, and copy symbol names directly.

---

## Part 2: Symbol Variants

Many symbols have multiple variants:

```swift
// Outline (default)
Image(systemName: "heart")

// Filled
Image(systemName: "heart.fill")

// Circle outline
Image(systemName: "heart.circle")

// Circle filled
Image(systemName: "heart.circle.fill")

// Slash (disabled/off state)
Image(systemName: "heart.slash")
Image(systemName: "heart.slash.fill")
```

### Common Variant Suffixes

| Suffix | Meaning | Example |
|--------|---------|---------|
| `.fill` | Solid filled | `star.fill` |
| `.circle` | In a circle | `star.circle` |
| `.square` | In a square | `star.square` |
| `.slash` | Crossed out | `bell.slash` |
| `.badge.plus` | With plus badge | `folder.badge.plus` |
| `.2`, `.3` | Multiple | `person.2`, `person.3` |

---

## Part 3: Rendering Modes

SF Symbols support different rendering modes for color:

### Monochrome (Default)

Single color, respects `foregroundStyle`:

```swift
Image(systemName: "cloud.sun.fill")
    .foregroundStyle(.blue)
// Everything is blue
```

### Hierarchical

Primary color with automatic opacity layers:

```swift
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.blue)
// Sun is full blue, cloud is lighter blue
```

### Palette

You specify colors for each layer:

```swift
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.palette)
    .foregroundStyle(.cyan, .yellow)
// Cloud is cyan, sun is yellow
```

### Multicolor

Apple's designed colors (not customizable):

```swift
Image(systemName: "cloud.sun.fill")
    .symbolRenderingMode(.multicolor)
// Uses Apple's built-in colors
```

---

## Part 4: Symbol Effects (iOS 17+)

NEW: SF Symbols 5 added built-in animations:

```swift
// Bounce effect
Image(systemName: "star.fill")
    .symbolEffect(.bounce, value: triggerValue)

// Pulse (subtle glow)
Image(systemName: "heart.fill")
    .symbolEffect(.pulse)

// Variable color (for multi-layer symbols)
Image(systemName: "wifi")
    .symbolEffect(.variableColor.iterative)

// Scale
Image(systemName: "plus.circle.fill")
    .symbolEffect(.scale.up, isActive: isPressed)
```

---

## Part 5: Building the CategoryIcon Component

Now let's build a reusable component for displaying category icons:

**File**: `StashMyStuff/DesignSystem/Components/CategoryIcon.swift`

```swift
//
//  CategoryIcon.swift
//  StashMyStuff
//

import SwiftUI

/// Displays a category's SF Symbol with proper styling
struct CategoryIcon: View {
    let category: Category
    let size: IconSize
    let style: IconStyle

    enum IconSize {
        case small      // 20pt - for list items
        case medium     // 28pt - for cards
        case large      // 44pt - for headers
        case extraLarge // 60pt - for empty states

        var font: Font {
            switch self {
            case .small: return .system(size: 20)
            case .medium: return .system(size: 28)
            case .large: return .system(size: 44)
            case .extraLarge: return .system(size: 60)
            }
        }

        var frameSize: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 64
            case .extraLarge: return 88
            }
        }
    }

    enum IconStyle {
        case plain      // Just the icon
        case circle     // In a circle background
        case filled     // In a filled circle
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
        let config = CategoryConfig.config(for: category)
        let symbolName = config?.icon ?? "questionmark"

        Group {
            switch style {
            case .plain:
                Image(systemName: symbolName)
                    .font(size.font)
                    .foregroundStyle(category.color)

            case .circle:
                Image(systemName: symbolName)
                    .font(size.font)
                    .foregroundStyle(category.color)
                    .frame(width: size.frameSize, height: size.frameSize)
                    .background {
                        Circle()
                            .fill(category.color.opacity(0.15))
                    }

            case .filled:
                Image(systemName: symbolName)
                    .font(size.font)
                    .foregroundStyle(.white)
                    .frame(width: size.frameSize, height: size.frameSize)
                    .background {
                        Circle()
                            .fill(category.color)
                    }
            }
        }
        .accessibilityLabel(category.rawValue)
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
```

---

## Part 6: Interactive Category Icon

Let's create a version that animates on tap (useful for selection):

```swift
// MARK: - Interactive Category Icon
struct InteractiveCategoryIcon: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            CategoryIcon(
                category,
                size: .medium,
                style: isSelected ? .filled : .circle
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .onLongPressGesture(
            minimumDuration: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: { }
        )
    }
}

#Preview("Interactive Icons") {
    struct PreviewWrapper: View {
        @State private var selected: Category? = .recipe

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
```

---

## Part 7: Flag Icon Helper

Since our `FlagDefinition` has icons, let's create a helper for those too:

```swift
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
        Image(systemName: flag.icon)
            .font(.system(size: size))
            .foregroundStyle(isActive ? .primary : .secondary)
            .symbolRenderingMode(isActive ? .hierarchical : .monochrome)
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
```

---

## Checkpoint: Verify Your Icons

Make sure all category icons display correctly:

```swift
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
```

---

## Exercise: Your Turn

### Exercise 1: Create a SourceIcon Component

Create a component that shows the favicon for a URL's domain:

```swift
SourceIcon(url: URL(string: "https://nytcooking.com")!)
// Shows a small icon representing the source
```

<details>
<summary>Hint</summary>

Use `AsyncImage` with the favicon URL pattern: `https://www.google.com/s2/favicons?domain=example.com&sz=64`

</details>

<details>
<summary>Solution</summary>

```swift
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
        AsyncImage(url: faviconURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            Image(systemName: "globe")
                .foregroundStyle(.secondary)
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
```

</details>

### Exercise 2: Animated Badge Icon

Create a notification-style badge icon that bounces when a value changes:

```swift
BadgeIcon(systemName: "bell", badgeCount: 3)
```

---

## What You Built

Icon components in `DesignSystem/Components/CategoryIcon.swift`:

1. **CategoryIcon** - Displays category SF Symbol with size/style options
2. **InteractiveCategoryIcon** - Tappable with selection animation
3. **FlagIcon** - Displays flag icons with active/inactive states

---

## SF Symbols Quick Reference

```swift
// Basic usage
Image(systemName: "star.fill")
    .font(.title)
    .foregroundStyle(.yellow)

// Rendering modes
.symbolRenderingMode(.hierarchical)  // Auto opacity layers
.symbolRenderingMode(.palette)       // Multiple colors
.symbolRenderingMode(.multicolor)    // Apple's colors

// Effects (iOS 17+)
.symbolEffect(.bounce, value: trigger)
.symbolEffect(.pulse)
.symbolEffect(.scale.up, isActive: isActive)

// Our components
CategoryIcon(.recipe, size: .large, style: .filled)
FlagIcon(flagDefinition, isActive: true)
```

---

## Useful Category Icons Reference

| Category | Icon Name | Notes |
|----------|-----------|-------|
| Recipes | `fork.knife` | Food-related |
| Books | `book.fill` | Reading |
| Movies | `film.fill` | Video content |
| Music | `music.note` | Audio |
| Clothes | `tshirt.fill` | Fashion |
| Home | `house.fill` | Home goods |
| Articles | `doc.text.fill` | Written content |
| Podcasts | `mic.fill` | Audio shows |
| Trips | `airplane` | Travel |
| Backpack | `backpack.fill` | Catch-all |

---

## Next Lesson

In **Lesson 2.5: Custom Button Styles**, you'll learn how to create branded button styles and build the `FlagButton` component for toggling item flags.

---

## Questions for Claude

When working through this lesson, you can ask:
- "How do I find the right SF Symbol for my use case?"
- "What's the difference between symbolRenderingMode and foregroundStyle?"
- "How do I make a symbol animate continuously?"
- "Can I use custom icons instead of SF Symbols?"

Reference this lesson as: **"Lesson 2.4 - SF Symbols"**
