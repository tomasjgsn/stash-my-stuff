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

## Part 2: iOS 26 Liquid Glass

iOS 26 introduced the **Liquid Glass** design language. SwiftUI provides the `.glassEffect()` modifier for native glass with refraction, depth, and dynamic lighting.

### The `.glassEffect()` API

```swift
// Basic signature
.glassEffect(_ style: GlassEffectStyle, in shape: some Shape)

// Common usage patterns
VStack { content }
    .glassEffect()                                      // Default glass

VStack { content }
    .glassEffect(.regular, in: .rect(cornerRadius: 16)) // Glass card

Button("Tap") { }
    .glassEffect(.regular.interactive(), in: .capsule)  // Glass button
```

**Key benefits:**
1. **True glass** — Refraction, depth, and dynamic lighting (not just blur)
2. **Automatic shadows** — System handles depth and elevation
3. **Press states** — `.interactive()` responds to touches automatically
4. **Performance** — GPU-accelerated, optimized by Apple
5. **Accessibility** — Respects Reduce Transparency settings automatically

### Create the Glass Modifier File

We create convenience modifiers that wrap `.glassEffect()` with our design tokens:

**File**: `StashMyStuff/DesignSystem/Modifiers/GlassModifier.swift`

```swift
//
//  GlassModifier.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Glass Card Modifier
struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    }
}

// MARK: - Interactive Glass Modifier (for buttons)
struct InteractiveGlassModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
    }
}

// MARK: - View Extension
extension View {
    /// Applies a glass card effect
    /// - Parameter cornerRadius: The corner radius (default: cardRadius = 16pt)
    func glassCard(
        cornerRadius: CGFloat = DesignTokens.Glass.cardRadius
    ) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius))
    }

    /// Applies an interactive glass effect (for buttons, tappable elements)
    /// - Parameter cornerRadius: The corner radius (default: buttonRadius = 12pt)
    func glassButton(
        cornerRadius: CGFloat = DesignTokens.Glass.buttonRadius
    ) -> some View {
        self.modifier(InteractiveGlassModifier(cornerRadius: cornerRadius))
    }
}
```

**What's happening:**
- `.glassEffect(.regular, ...)` provides the native Liquid Glass look
- `.interactive()` adds press-state feedback for buttons
- Our modifiers wrap the API with semantic naming and default tokens

### Test the Glass Effect

Add a preview at the bottom:

```swift
// MARK: - Preview
#Preview("Liquid Glass") {
    ZStack {
        // Colorful background to show the glass effect
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
                Text("This is content inside a glass card with true Liquid Glass effect.")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(.secondary)
            }
            .padding(DesignTokens.Spacing.lg)
            .glassCard()

            // Interactive glass button
            Button {
                print("Tapped!")
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("Featured Item")
                }
                .padding(DesignTokens.Spacing.md)
            }
            .glassButton()
        }
        .padding()
    }
}
```

---

## Part 3: Glass Card with Padding

A complete glass card combines padding with the glass effect. Update the modifier:

```swift
// MARK: - Glass Card Modifier (with padding)
struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
    }
}

extension View {
    /// Applies a complete glass card style with padding
    func glassCard(
        cornerRadius: CGFloat = DesignTokens.Glass.cardRadius,
        padding: CGFloat = DesignTokens.Spacing.lg
    ) -> some View {
        self.modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            padding: padding
        ))
    }
}
```

**Note:** `.glassEffect()` automatically adapts to light/dark mode and respects accessibility settings like Reduce Transparency.

Now you can apply a complete card style with one modifier:

```swift
VStack {
    Text("Title")
    Text("Description")
}
.glassCard()  // Adds padding and native Liquid Glass!
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

## Part 6: Shadow Modifier Helper (For Non-Glass Elements)

While iOS 26's `.glassEffect()` handles shadows automatically for glass elements, you'll still need manual shadows for non-glass views (images, solid backgrounds, etc.).

Add to `GlassModifier.swift`:

```swift
// MARK: - Shadow Modifier
extension View {
    /// Applies a design token shadow (for non-glass elements)
    /// Note: Glass elements don't need this - .glassEffect() handles depth automatically
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

Use this for non-glass elements:
```swift
// Non-glass image card - needs manual shadow
Image("photo")
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(DesignTokens.Shadows.md)

// Glass card - shadow handled automatically
VStack { content }
    .glassCard()  // No need for .shadow() - Liquid Glass handles it
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
   - `.glassCard()` - Native Liquid Glass card with padding
   - `.glassButton()` - Interactive glass for tappable elements
   - `.shadow(Shadow)` - Token-based shadows (for non-glass elements)

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
