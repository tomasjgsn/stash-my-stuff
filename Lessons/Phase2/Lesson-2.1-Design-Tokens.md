# Lesson 2.1: Design Tokens in Swift

> **Type**: Micro-lesson (10-15 min)
> **Concepts**: NEW - SwiftUI Color, enums with static properties, type-safe design systems
> **Builds**: `DesignSystem/DesignTokens.swift`

---

## What You'll Learn

Design tokens are the "atoms" of a design system - the smallest, indivisible values like colors, spacing, and typography. In this lesson, you'll create a centralized design token system for Stash My Stuff that ensures visual consistency across the entire app.

---

## Why Design Tokens?

Think of design tokens like constants in programming. Instead of hardcoding `Color.blue` everywhere, you define `DesignTokens.Colors.primary` once. Benefits:

1. **Consistency**: Every button uses the same color
2. **Easy changes**: Update one value, change everywhere
3. **Self-documenting**: `Colors.categoryRecipe` is clearer than `Color.orange`
4. **Dark mode support**: Tokens automatically adapt

**Python/MATLAB analogy**: This is like defining constants at the top of your script:
```python
# Python
PRIMARY_COLOR = "#007AFF"
SPACING_SMALL = 8
FONT_SIZE_BODY = 16
```

In Swift, we'll do this with more type safety using enums and static properties.

---

## Part 1: Understanding SwiftUI Colors

### NEW: SwiftUI's Color Type

SwiftUI provides a `Color` type that works across iOS, macOS, watchOS, and tvOS. Colors can be:

```swift
// System colors (adapt to light/dark mode)
Color.blue          // System blue
Color.primary       // Primary text (black in light, white in dark)
Color.secondary     // Secondary text (gray, adapts)

// Custom hex colors
Color(hex: "FF5733")  // We'll create this extension

// Asset catalog colors
Color("CustomColorName")  // Defined in Assets.xcassets
```

### NEW: Color from Hex

Swift doesn't have built-in hex color support, so we'll add it. Create a new file first:

**File**: `StashMyStuff/DesignSystem/DesignTokens.swift`

```swift
//
//  DesignTokens.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Color Extension for Hex
extension Color {
    /// Creates a Color from a hex string like "FF5733" or "#FF5733"
    init(hex: String) {
        // Remove # if present
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: UInt64
        switch hex.count {
        case 6: // RGB (no alpha)
            (r, g, b, a) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF, 255)
        case 8: // RGBA
            (r, g, b, a) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
```

**What's happening here:**
- `extension Color` adds new functionality to the existing Color type
- `Scanner` parses the hex string into a number
- Bit shifting (`>>`) extracts RGB components from the number
- The `init` creates the color with red, green, blue values from 0-1

---

## Part 2: Building the Design Token System

### NEW: Organizing with Nested Enums

Swift lets us nest enums and structs to create namespaces. This is cleaner than prefixing everything:

```swift
// Instead of:
let colorPrimary = Color.blue
let colorSecondary = Color.gray
let spacingSmall = 8.0

// We do:
DesignTokens.Colors.primary
DesignTokens.Spacing.small
```

Add this to your `DesignTokens.swift` file:

```swift
// MARK: - Design Tokens
enum DesignTokens {
    // Tokens will be organized inside here
}
```

### Colors Token

Add inside the `DesignTokens` enum:

```swift
// MARK: - Colors
enum Colors {
    // MARK: Category Colors
    // These match our CategoryConfig colors but as actual SwiftUI Colors
    static let categoryRecipe = Color.orange
    static let categoryBook = Color.indigo
    static let categoryMovie = Color.purple
    static let categoryMusic = Color.pink
    static let categoryClothes = Color.teal
    static let categoryHome = Color.brown
    static let categoryArticle = Color.blue
    static let categoryPodcast = Color.green
    static let categoryTrip = Color.cyan
    static let categoryBackpack = Color.gray

    // MARK: Semantic Colors
    static let primary = Color.primary           // Main text
    static let secondary = Color.secondary       // Subtitle text
    static let accent = Color.accentColor        // Tappable elements
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)

    // MARK: Feedback Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red

    // MARK: Glass Effect Colors
    static let glassFill = Color.white.opacity(0.15)
    static let glassBorder = Color.white.opacity(0.3)
    static let glassShadow = Color.black.opacity(0.15)
}
```

**Note**: `Color(.systemBackground)` uses UIColor/NSColor underneath, which properly adapts to light/dark mode on each platform.

### Spacing Token

Add this inside `DesignTokens`:

```swift
// MARK: - Spacing
enum Spacing {
    /// 4pt - Minimal spacing (between icon and label)
    static let xxs: CGFloat = 4

    /// 8pt - Small spacing (list item padding)
    static let xs: CGFloat = 8

    /// 12pt - Medium-small spacing
    static let sm: CGFloat = 12

    /// 16pt - Medium spacing (standard padding)
    static let md: CGFloat = 16

    /// 20pt - Medium-large spacing
    static let lg: CGFloat = 20

    /// 24pt - Large spacing (section separation)
    static let xl: CGFloat = 24

    /// 32pt - Extra large spacing
    static let xxl: CGFloat = 32
}
```

**Why CGFloat?** SwiftUI layout uses `CGFloat` (Core Graphics Float), not `Double`. They're mostly interchangeable in Swift 5.5+, but `CGFloat` is idiomatic for UI code.

### Typography Token

Add this inside `DesignTokens`:

```swift
// MARK: - Typography
enum Typography {
    // Font sizes following Apple's Human Interface Guidelines
    static let largeTitle: Font = .largeTitle       // 34pt
    static let title: Font = .title                 // 28pt
    static let title2: Font = .title2               // 22pt
    static let title3: Font = .title3               // 20pt
    static let headline: Font = .headline           // 17pt semibold
    static let body: Font = .body                   // 17pt
    static let callout: Font = .callout             // 16pt
    static let subheadline: Font = .subheadline     // 15pt
    static let footnote: Font = .footnote           // 13pt
    static let caption: Font = .caption             // 12pt
    static let caption2: Font = .caption2           // 11pt

    // Custom variants using SF Pro Rounded (app's personality)
    static let titleRounded: Font = .system(.title, design: .rounded, weight: .bold)
    static let headlineRounded: Font = .system(.headline, design: .rounded, weight: .semibold)
    static let bodyRounded: Font = .system(.body, design: .rounded)
}
```

### Radius Token (Corner Radii)

Add this inside `DesignTokens`:

```swift
// MARK: - Radius (Corner Radii)
enum Radius {
    /// 4pt - Subtle rounding (small buttons)
    static let xs: CGFloat = 4

    /// 8pt - Small rounding (chips, tags)
    static let sm: CGFloat = 8

    /// 12pt - Medium rounding (buttons, inputs)
    static let md: CGFloat = 12

    /// 16pt - Large rounding (cards)
    static let lg: CGFloat = 16

    /// 20pt - Extra large rounding (glass cards)
    static let xl: CGFloat = 20

    /// Full circle (for circular buttons/avatars)
    static func circle(size: CGFloat) -> CGFloat {
        size / 2
    }
}
```

### Shadow Token

Add this inside `DesignTokens`:

```swift
// MARK: - Shadows
enum Shadows {
    /// Subtle shadow for slight elevation
    static let sm = Shadow(
        color: Colors.glassShadow,
        radius: 4,
        x: 0,
        y: 2
    )

    /// Medium shadow for cards
    static let md = Shadow(
        color: Colors.glassShadow,
        radius: 8,
        x: 0,
        y: 4
    )

    /// Large shadow for modals/sheets
    static let lg = Shadow(
        color: Colors.glassShadow,
        radius: 16,
        x: 0,
        y: 8
    )
}

// Shadow struct to hold all values together
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
```

---

## Part 3: Category Color Helper

Since we have colors defined in `CategoryConfig` as strings, let's add a helper to get the actual SwiftUI Color:

Add this extension at the bottom of the file (outside the `DesignTokens` enum):

```swift
// MARK: - Category Color Extension
extension Category {
    /// Returns the SwiftUI Color for this category
    var color: Color {
        switch self {
        case .recipe: return DesignTokens.Colors.categoryRecipe
        case .book: return DesignTokens.Colors.categoryBook
        case .movie: return DesignTokens.Colors.categoryMovie
        case .music: return DesignTokens.Colors.categoryMusic
        case .clothes: return DesignTokens.Colors.categoryClothes
        case .home: return DesignTokens.Colors.categoryHome
        case .article: return DesignTokens.Colors.categoryArticle
        case .podcast: return DesignTokens.Colors.categoryPodcast
        case .trip: return DesignTokens.Colors.categoryTrip
        case .backpack: return DesignTokens.Colors.categoryBackpack
        }
    }
}
```

Now you can use `Category.recipe.color` anywhere!

---

## Checkpoint: Test Your Tokens

Create a preview to verify your tokens work. Add at the bottom of the file:

```swift
// MARK: - Preview
#Preview("Design Tokens") {
    ScrollView {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {

            // Category Colors
            Text("Category Colors")
                .font(DesignTokens.Typography.titleRounded)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: DesignTokens.Spacing.sm) {
                ForEach(Category.allCases, id: \.self) { category in
                    VStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 44, height: 44)
                        Text(category.rawValue)
                            .font(DesignTokens.Typography.caption)
                            .lineLimit(1)
                    }
                }
            }

            Divider()

            // Spacing Demo
            Text("Spacing Scale")
                .font(DesignTokens.Typography.titleRounded)

            HStack(spacing: 0) {
                spacingBox(DesignTokens.Spacing.xxs, "xxs")
                spacingBox(DesignTokens.Spacing.xs, "xs")
                spacingBox(DesignTokens.Spacing.sm, "sm")
                spacingBox(DesignTokens.Spacing.md, "md")
                spacingBox(DesignTokens.Spacing.lg, "lg")
                spacingBox(DesignTokens.Spacing.xl, "xl")
            }

            Divider()

            // Typography Demo
            Text("Typography")
                .font(DesignTokens.Typography.titleRounded)

            Text("Large Title").font(DesignTokens.Typography.largeTitle)
            Text("Title").font(DesignTokens.Typography.title)
            Text("Headline").font(DesignTokens.Typography.headline)
            Text("Body").font(DesignTokens.Typography.body)
            Text("Caption").font(DesignTokens.Typography.caption)

            Text("Title Rounded").font(DesignTokens.Typography.titleRounded)
            Text("Body Rounded").font(DesignTokens.Typography.bodyRounded)
        }
        .padding(DesignTokens.Spacing.lg)
    }
}

@ViewBuilder
private func spacingBox(_ size: CGFloat, _ label: String) -> some View {
    VStack {
        Rectangle()
            .fill(DesignTokens.Colors.accent)
            .frame(width: size, height: 40)
        Text(label)
            .font(DesignTokens.Typography.caption2)
        Text("\(Int(size))pt")
            .font(DesignTokens.Typography.caption2)
            .foregroundStyle(DesignTokens.Colors.secondary)
    }
    .padding(.horizontal, 4)
}
```

---

## Exercise: Your Turn

Before moving on, try these exercises:

### Exercise 1: Add Animation Duration Tokens

Add a new `Animation` enum inside `DesignTokens` with:
- `quick`: 0.15 seconds
- `standard`: 0.3 seconds
- `slow`: 0.5 seconds

<details>
<summary>Solution</summary>

```swift
// MARK: - Animation Durations
enum AnimationDuration {
    static let quick: Double = 0.15
    static let standard: Double = 0.3
    static let slow: Double = 0.5
}
```

</details>

### Exercise 2: Add an Icon Size Token

Add an `IconSize` enum with:
- `sm`: 16pt
- `md`: 24pt
- `lg`: 32pt
- `xl`: 44pt (standard tap target)

<details>
<summary>Solution</summary>

```swift
// MARK: - Icon Sizes
enum IconSize {
    static let sm: CGFloat = 16
    static let md: CGFloat = 24
    static let lg: CGFloat = 32
    static let xl: CGFloat = 44  // Apple's minimum tap target
}
```

</details>

---

## What You Built

You now have a complete design token system at `StashMyStuff/DesignSystem/DesignTokens.swift`:

- **Colors**: Category colors, semantic colors, glass effect colors
- **Spacing**: Consistent 4pt-based spacing scale
- **Typography**: System fonts + rounded variants for personality
- **Radius**: Corner radii from subtle to large
- **Shadows**: Elevation levels for depth

This foundation will be used by every component you build in Phase 2.

---

## Quick Reference

```swift
// Colors
DesignTokens.Colors.categoryRecipe    // Orange
DesignTokens.Colors.primary           // Adaptive text color
Category.book.color                   // Get color from category

// Spacing
DesignTokens.Spacing.md               // 16pt
DesignTokens.Spacing.lg               // 20pt

// Typography
DesignTokens.Typography.headline      // System headline
DesignTokens.Typography.titleRounded  // SF Pro Rounded title

// Radius
DesignTokens.Radius.lg                // 16pt for cards

// Shadows
DesignTokens.Shadows.md               // Card shadow
```

---

## Next Lesson

In **Lesson 2.2: View Modifiers Deep Dive**, you'll learn how to create custom view modifiers that apply these tokens automatically, like `.glassCard()` and `.categoryAccent()`.

---

## Questions for Claude

When working through this lesson, you can ask Claude questions like:
- "Why does SwiftUI use CGFloat instead of Double?"
- "How do I create a custom color in the asset catalog?"
- "What's the difference between Color.primary and Color.accentColor?"
- "Can you explain the bit shifting in the hex color extension?"

Reference this lesson as: **"Lesson 2.1 - Design Tokens"**
