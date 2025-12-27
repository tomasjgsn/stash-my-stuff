# Lesson 2.2: View Modifiers Deep Dive

> **Type**: Standard lesson (20-30 min)
> **Concepts**: NEW - ViewModifier protocol, @ViewBuilder, conditional modifiers
> **Builds**: `DesignSystem/Modifiers/GlassModifier.swift`, `DesignSystem/Modifiers/CategoryModifier.swift`

---

## What You'll Learn

View modifiers are the heart of SwiftUI styling. In this lesson, you'll understand how they work under the hood and create custom modifiers for the Stash My Stuff design system.

---

## Prerequisites

Complete **Lesson 2.1** first - you'll use the `DesignTokens` you created.

---

## Part 1: Understanding View Modifiers

### What is a View Modifier?

Every time you write `.padding()` or `.background()`, you're using a view modifier. They transform one view into another:

```swift
Text("Hello")           // Original view
    .padding()          // Returns a new modified view
    .background(.blue)  // Returns another new modified view
```

**Python analogy**: Think of decorators that wrap functions:
```python
@cached
@logged
def my_function():
    pass
```

Each modifier wraps the previous view, creating a chain.

### The ViewModifier Protocol

SwiftUI has a `ViewModifier` protocol with one requirement:

```swift
protocol ViewModifier {
    associatedtype Body: View
    func body(content: Content) -> Body
}
```

- `content` is the view being modified
- You return a new view that includes `content` plus your modifications

### Simple Example

```swift
struct RedBorderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .border(Color.red, width: 2)
    }
}

// Usage (awkward)
Text("Hello").modifier(RedBorderModifier())

// Better: Create an extension
extension View {
    func redBorder() -> some View {
        self.modifier(RedBorderModifier())
    }
}

// Clean usage
Text("Hello").redBorder()
```

---

## Part 2: Building the Glass Effect Modifier

Let's create the signature "Liquid Glass" effect for our app.

### Create the File

Create a new folder and file:

**File**: `StashMyStuff/DesignSystem/Modifiers/GlassModifier.swift`

```swift
//
//  GlassModifier.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Glass Background Modifier
struct GlassBackgroundModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .background {
                // Glass effect: blur + fill + border
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)  // System blur material
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                DesignTokens.Colors.glassBorder,
                                lineWidth: 1
                            )
                    }
            }
    }
}

// MARK: - View Extension
extension View {
    /// Applies a glass morphism background effect
    /// - Parameter cornerRadius: The corner radius (default: lg = 16pt)
    func glassBackground(cornerRadius: CGFloat = DesignTokens.Radius.lg) -> some View {
        self.modifier(GlassBackgroundModifier(cornerRadius: cornerRadius))
    }
}
```

**What's happening:**
- `.ultraThinMaterial` is Apple's built-in blur effect that adapts to light/dark mode
- The `overlay` adds a subtle border for definition
- We parameterize `cornerRadius` so it's flexible

### Test the Glass Effect

Add a preview at the bottom:

```swift
// MARK: - Preview
#Preview("Glass Background") {
    ZStack {
        // Colorful background to show the blur effect
        LinearGradient(
            colors: [.purple, .blue, .cyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: DesignTokens.Spacing.lg) {
            // Card with glass effect
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Glass Card")
                    .font(DesignTokens.Typography.headline)
                Text("This is content inside a glass card. Notice how the background shows through with a blur effect.")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(.secondary)
            }
            .padding(DesignTokens.Spacing.lg)
            .glassBackground()

            // Another card
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("Featured Item")
            }
            .padding(DesignTokens.Spacing.md)
            .glassBackground(cornerRadius: DesignTokens.Radius.xl)
        }
        .padding()
    }
}
```

---

## Part 3: Glass Card Modifier with Shadow

A complete glass card needs padding, background, AND shadow. Let's create a compound modifier:

Add to the same file:

```swift
// MARK: - Glass Card Modifier
struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let padding: CGFloat
    let shadow: Shadow

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(DesignTokens.Colors.glassBorder, lineWidth: 1)
                    }
                    .shadow(
                        color: shadow.color,
                        radius: shadow.radius,
                        x: shadow.x,
                        y: shadow.y
                    )
            }
    }
}

extension View {
    /// Applies a complete glass card style with padding and shadow
    func glassCard(
        cornerRadius: CGFloat = DesignTokens.Radius.xl,
        padding: CGFloat = DesignTokens.Spacing.lg,
        shadow: Shadow = DesignTokens.Shadows.md
    ) -> some View {
        self.modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            padding: padding,
            shadow: shadow
        ))
    }
}
```

Now you can apply a complete card style with one modifier:

```swift
VStack {
    Text("Title")
    Text("Description")
}
.glassCard()  // Adds padding, background, border, and shadow!
```

---

## Part 4: Category Accent Modifier

Let's create a modifier that styles views with their category color:

**File**: `StashMyStuff/DesignSystem/Modifiers/CategoryModifier.swift`

```swift
//
//  CategoryModifier.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Category Accent Modifier
struct CategoryAccentModifier: ViewModifier {
    let category: Category

    func body(content: Content) -> some View {
        content
            .tint(category.color)
            .foregroundStyle(category.color)
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
            .background(category.color.opacity(0.15))
            .foregroundStyle(category.color)
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
```

---

## Part 5: Conditional Modifiers

Sometimes you want to apply a modifier only when a condition is true. There are several patterns:

### Pattern 1: Ternary in Modifier Parameters

```swift
Text("Hello")
    .foregroundStyle(isSelected ? .blue : .gray)
```

### Pattern 2: Custom Conditional Modifier

Add this to a new utilities file:

**File**: `StashMyStuff/DesignSystem/Modifiers/ConditionalModifiers.swift`

```swift
//
//  ConditionalModifiers.swift
//  StashMyStuff
//

import SwiftUI

extension View {
    /// Applies a modifier only when a condition is true
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies one modifier when true, another when false
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if ifTransform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            ifTransform(self)
        } else {
            elseTransform(self)
        }
    }
}
```

**What's NEW here:**
- `@ViewBuilder` allows the function to return different view types from if/else
- Backticks around `if` let us use a keyword as a function name
- This enables clean conditional styling:

```swift
Text("Item")
    .if(isHighlighted) { view in
        view
            .background(.yellow)
            .fontWeight(.bold)
    }
```

### Pattern 3: Optional-Based Modifier

```swift
extension View {
    /// Applies a modifier if the optional has a value
    @ViewBuilder
    func ifLet<T, Content: View>(_ optional: T?, transform: (Self, T) -> Content) -> some View {
        if let value = optional {
            transform(self, value)
        } else {
            self
        }
    }
}

// Usage
Text("Item")
    .ifLet(item.imageURL) { view, url in
        view.overlay(AsyncImage(url: url))
    }
```

---

## Part 6: Shadow Modifier Helper

Let's create a nicer API for our shadow tokens:

Add to `GlassModifier.swift`:

```swift
// MARK: - Shadow Modifier
extension View {
    /// Applies a design token shadow
    func shadow(_ shadow: Shadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}
```

Now you can write:
```swift
Card()
    .shadow(DesignTokens.Shadows.md)
```

Instead of:
```swift
Card()
    .shadow(
        color: DesignTokens.Shadows.md.color,
        radius: DesignTokens.Shadows.md.radius,
        x: DesignTokens.Shadows.md.x,
        y: DesignTokens.Shadows.md.y
    )
```

---

## Checkpoint: Full Preview

Create a comprehensive preview to test all modifiers:

```swift
#Preview("All Modifiers") {
    ZStack {
        LinearGradient(
            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Glass cards
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Glass Card")
                        .font(DesignTokens.Typography.headline)
                    Text("Complete glass card with .glassCard() modifier")
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()

                // Category badges
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Category Badges")
                        .font(DesignTokens.Typography.headline)

                    FlowLayout(spacing: DesignTokens.Spacing.xs) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue)
                                .categoryBadge(category)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()

                // Category icons
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text("Category Icons")
                        .font(DesignTokens.Typography.headline)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))]) {
                        ForEach(Category.allCases, id: \.self) { category in
                            if let config = CategoryConfig.config(for: category) {
                                Image(systemName: config.icon)
                                    .font(.title)
                                    .categoryAccent(category)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassCard()
            }
            .padding()
        }
    }
}

// Simple flow layout for badges
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
```

---

## Exercise: Your Turn

### Exercise 1: Create a Favorite Badge Modifier

Create a modifier that adds a small heart icon overlay to any view when an item is favorited:

```swift
// Target usage:
Image("thumbnail")
    .favoriteBadge(isFavorite: item.isFavorite)
```

<details>
<summary>Solution</summary>

```swift
struct FavoriteBadgeModifier: ViewModifier {
    let isFavorite: Bool

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if isFavorite {
                    Image(systemName: "heart.fill")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.red)
                        .padding(DesignTokens.Spacing.xxs)
                        .background(.white.opacity(0.9))
                        .clipShape(Circle())
                        .offset(x: 4, y: -4)
                }
            }
    }
}

extension View {
    func favoriteBadge(isFavorite: Bool) -> some View {
        self.modifier(FavoriteBadgeModifier(isFavorite: isFavorite))
    }
}
```

</details>

### Exercise 2: Create a Highlight Modifier

Create a modifier that adds a pulsing glow effect for "new" items:

<details>
<summary>Hint</summary>

Use `.shadow()` with a larger radius and animate it with `@State` and `.animation()`.

</details>

---

## What You Built

You now have a set of reusable modifiers in `DesignSystem/Modifiers/`:

1. **GlassModifier.swift**
   - `.glassBackground()` - Just the blur effect
   - `.glassCard()` - Complete card with padding and shadow
   - `.shadow(Shadow)` - Apply token-based shadows

2. **CategoryModifier.swift**
   - `.categoryAccent()` - Tint with category color
   - `.categoryBadge()` - Styled pill badge

3. **ConditionalModifiers.swift**
   - `.if(condition)` - Conditional modifier application
   - `.ifLet(optional)` - Optional-based modifier

---

## Key Concepts Learned

| Concept | What It Does |
|---------|--------------|
| `ViewModifier` protocol | Defines how to wrap and transform views |
| `@ViewBuilder` | Enables conditional view returns |
| `.modifier()` | Applies a ViewModifier struct |
| Extension on `View` | Creates clean `.myModifier()` syntax |
| Compound modifiers | Combine multiple effects in one call |

---

## Next Lesson

In **Lesson 2.3: Building GlassCard Component**, you'll create a complete reusable `GlassCard` view component that uses these modifiers internally and exposes a clean API.

---

## Questions for Claude

When working through this lesson, you can ask:
- "What's the difference between a ViewModifier and a View?"
- "When should I use @ViewBuilder?"
- "How do I animate a custom modifier?"
- "Can you explain the FlowLayout code?"

Reference this lesson as: **"Lesson 2.2 - View Modifiers"**
