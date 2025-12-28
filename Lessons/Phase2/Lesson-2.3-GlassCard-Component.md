# Lesson 2.3: Building the GlassCard Component

> **Type**: Standard lesson (25-30 min)
> **Concepts**: NEW - Generic View components, @ViewBuilder closures, component composition
> **Builds**: `DesignSystem/Components/GlassCard.swift`

---

## What You'll Learn

In this lesson, you'll create a complete `GlassCard` component - a reusable container that wraps any content in the signature glass effect. This teaches you how to build flexible, composable SwiftUI components.

---

## Prerequisites

Complete **Lessons 2.1 and 2.2** - you'll use DesignTokens and the glass modifiers.

---

## Apple's Liquid Glass Guidelines

Before building components, understand Apple's design philosophy:

| Principle | Description |
|-----------|-------------|
| **Hierarchy** | Glass floats on the navigation layer; content sits below |
| **Content-First** | UI elements recede when users are reading/creating |
| **Interactive Mode** | Use `.interactive()` for tappable elements |
| **Readability** | Maintain strong text/icon contrast against glass |
| **Accessibility** | Support Dynamic Type; maintain contrast ratios |

**Key Rule**: Glass is for controls and navigation, not content. Content extends to edges while glass elements float above.

---

## Part 1: View Components vs Modifiers

### When to Use Each

| Use a Modifier When... | Use a Component When... |
|------------------------|-------------------------|
| Adding a visual effect (shadow, background) | Creating a self-contained piece of UI |
| The structure doesn't change | You need to control the layout |
| Simple transformation | Complex composition of multiple views |
| `.padding()`, `.background()` | `GlassCard`, `StashItemRow` |

For our glass card, we want more control: a header slot, content slot, and optional footer. That means a component.

### The Building Block: @ViewBuilder

**NEW Concept**: `@ViewBuilder` is a Swift attribute that lets a function or closure return views built with SwiftUI's DSL syntax:

```swift
// Without @ViewBuilder - can only return ONE view
func makeView() -> some View {
    Text("Hello")  // Works
    // Text("World")  // ERROR: Can't have multiple statements
}

// With @ViewBuilder - can use SwiftUI DSL
@ViewBuilder
func makeView() -> some View {
    Text("Hello")
    Text("World")
    if showExtra {
        Text("Extra")
    }
}
```

---

## Part 2: Basic GlassCard Component

Create the component file:

**File**: `StashMyStuff/DesignSystem/Components/GlassCard.swift`

```swift
//
//  GlassCard.swift
//  StashMyStuff
//

import SwiftUI

/// A Liquid Glass card container using iOS 26's native .glassEffect()
struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .glassCard()  // Uses the modifier from Lesson 2.2
    }
}

// MARK: - Preview
#Preview("Basic GlassCard") {
    ZStack {
        LinearGradient(
            colors: [.purple, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        GlassCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("My Glass Card")
                    .font(DesignTokens.Typography.headline)
                Text("This content is wrapped in native Liquid Glass.")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
}
```

**What's happening:**
- `GlassCard<Content: View>` is a generic type - `Content` can be ANY view type
- `@ViewBuilder content: () -> Content` accepts a closure that builds views
- `content()` executes the closure and stores the result
- The body applies our `.glassCard()` modifier which uses `.glassEffect()`

### Why `() -> Content` instead of just `Content`?

Using a closure (`() -> Content`) enables SwiftUI's trailing closure syntax:

```swift
// With closure - clean syntax
GlassCard {
    Text("Hello")
    Text("World")
}

// Without closure - awkward
GlassCard(content: VStack {
    Text("Hello")
    Text("World")
})
```

---

## Part 3: Adding Customization Options

Let's add parameters for corner radius and interactive mode:

```swift
struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let isInteractive: Bool
    let content: Content

    init(
        cornerRadius: CGFloat = DesignTokens.Glass.cardRadius,
        isInteractive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.isInteractive = isInteractive
        self.content = content()
    }

    var body: some View {
        content
            .glassEffect(
                isInteractive ? .regular.interactive() : .regular,
                in: .rect(cornerRadius: cornerRadius)
            )
    }
}
```

Now you can customize:

```swift
// Default glass card
GlassCard { content }

// Custom corner radius
GlassCard(cornerRadius: DesignTokens.Radius.sm) { content }

// Interactive (for tappable cards)
GlassCard(isInteractive: true) { content }  // Responds to press states
```

---

## Part 4: Adding Header and Footer Slots

For more complex cards, let's add optional header and footer sections:

```swift
//
//  GlassCard.swift
//  StashMyStuff
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
        VStack(alignment: .leading, spacing: spacing) {
            if let header {
                header
            }

            content

            if let footer {
                footer
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.lg)
        .glassEffect(
            isInteractive ? .regular.interactive() : .regular,
            in: .rect(cornerRadius: cornerRadius)
        )
    }
}
```

**What's NEW here:**
- `where Header == EmptyView` constrains which initializer is used
- `EmptyView` is SwiftUI's "nothing" view - takes no space
- Multiple initializers give flexible APIs without cluttering call sites

### Usage Examples

```swift
// Content only
GlassCard {
    Text("Simple content")
}

// With header
GlassCard {
    Text("Header")
        .font(.headline)
} content: {
    Text("Main content here")
}

// Full card with header, content, footer
GlassCard {
    HStack {
        Text("Recipe")
        Spacer()
        Image(systemName: "fork.knife")
    }
    .font(.headline)
} content: {
    Text("Grandma's Famous Cookies")
        .font(.title2)
    Text("The best chocolate chip cookies you'll ever taste.")
        .foregroundStyle(.secondary)
} footer: {
    HStack {
        Label("45 min", systemImage: "clock")
        Spacer()
        Button("View Recipe") { }
    }
    .font(.caption)
}
```

---

## Part 5: Creating Preset Card Styles

Let's create some convenient preset styles for common use cases:

```swift
// MARK: - Preset Styles
extension GlassCard where Header == EmptyView, Footer == EmptyView {
    /// A card optimized for list items (smaller corners)
    static func listItem(
        @ViewBuilder content: () -> Content
    ) -> GlassCard {
        GlassCard(
            cornerRadius: DesignTokens.Glass.chipRadius,
            isInteractive: true,  // List items are usually tappable
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
```

Usage:
```swift
GlassCard.listItem {
    Text("Quick list item")
}

GlassCard.featured {
    Text("Big important content")
}
```

---

## Part 6: Category-Tinted Glass Card

Let's create a variant that adds a subtle category color tint using Apple's official `.tint()` API:

```swift
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
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Spacing.lg)
            .glassEffect(
                // Use Apple's official .tint() API for colored glass
                isInteractive
                    ? .regular.tint(category.color).interactive()
                    : .regular.tint(category.color),
                in: .rect(cornerRadius: DesignTokens.Glass.cardRadius)
            )
    }
}
```

**What's NEW here:**
- `.tint(category.color)` is Apple's official API for colored Liquid Glass
- The glass material adapts automatically - no manual background/overlay needed
- Adding `.interactive()` makes it respond to taps
- This approach ensures proper contrast and accessibility

// MARK: - Preview
#Preview("Category Glass Cards") {
    ZStack {
        LinearGradient(
            colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
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
```

---

## Part 7: GlassEffectContainer (Preview)

**Advanced Concept**: For morphing animations between glass elements (covered in Lesson 2.8), you'll use `GlassEffectContainer`:

```swift
// GlassEffectContainer groups glass shapes for morphing
@Namespace private var glassNamespace

GlassEffectContainer {
    if isExpanded {
        ExpandedCard()
            .glassEffect(.regular, in: .rect(cornerRadius: 20))
            .glassEffectID("card", in: glassNamespace)
    } else {
        CollapsedCard()
            .glassEffect(.regular, in: .rect(cornerRadius: 12))
            .glassEffectID("card", in: glassNamespace)
    }
}
```

**Key Points:**
- Wrap glass elements in `GlassEffectContainer` when they need to morph
- Use `.glassEffectID(_:in:)` with a `@Namespace` for tracking
- SwiftUI automatically animates shape transitions

We'll implement this fully in **Lesson 2.8: Animations and Haptics**.

---

## Part 8: Complete Preview Suite

Add a comprehensive preview at the end of the file:

```swift
// MARK: - All Previews
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

                // Preset styles
                GlassCard.listItem {
                    HStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 44, height: 44)
                        VStack(alignment: .leading) {
                            Text("List Item Style")
                                .font(DesignTokens.Typography.headline)
                            Text("Smaller padding and shadow")
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
    }
}
```

---

## Exercise: Your Turn

### Exercise 1: Create an Expandable Glass Card

Create a `ExpandableGlassCard` that shows a preview and expands to show full content when tapped:

```swift
ExpandableGlassCard(isExpanded: $isExpanded) {
    // Preview content (always shown)
    Text("Tap to expand")
} expanded: {
    // Full content (shown when expanded)
    Text("Here's all the extra details...")
}
```

<details>
<summary>Hint</summary>

Use `@Binding var isExpanded: Bool` and conditional rendering with animation.

</details>

<details>
<summary>Solution</summary>

```swift
struct ExpandableGlassCard<Preview: View, Expanded: View>: View {
    @Binding var isExpanded: Bool
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
        GlassCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                preview

                if isExpanded {
                    Divider()
                    expanded
                }
            }
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }
    }
}
```

</details>

### Exercise 2: Add an Icon Badge

Modify `GlassCard` to optionally show a small icon badge in the top-right corner.

---

## What You Built

A complete `GlassCard` component system in `DesignSystem/Components/GlassCard.swift`:

1. **Basic `GlassCard`** - Generic container with customizable radius/shadow
2. **Multi-slot `GlassCard`** - Header, content, and footer slots
3. **Preset styles** - `.listItem()` and `.featured()` convenience methods
4. **`CategoryGlassCard`** - Tinted variant for category-specific UI

---

## Key Concepts Learned

| Concept | What You Learned |
|---------|------------------|
| Generic Views | `<Content: View>` for type-flexible components |
| @ViewBuilder | Enables SwiftUI DSL in closures |
| Multiple initializers | Different APIs for different use cases |
| `where` clauses | Constrain generics in specific initializers |
| EmptyView | SwiftUI's "nothing" placeholder |
| Preset methods | Static methods for common configurations |
| `.tint()` API | Official way to add color to Liquid Glass |
| `.interactive()` | Makes glass respond to touch states |
| GlassEffectContainer | Groups glass shapes for morphing (preview) |

---

## File Structure So Far

```
StashMyStuff/
└── DesignSystem/
    ├── DesignTokens.swift           (Lesson 2.1)
    ├── Modifiers/
    │   ├── GlassModifier.swift      (Lesson 2.2)
    │   ├── CategoryModifier.swift   (Lesson 2.2)
    │   ├── ConditionalModifiers.swift (Lesson 2.2)
    │   └── BadgeModifiers.swift     (Lesson 2.2)
    └── Components/
        └── GlassCard.swift          (This lesson)
```

---

## Next Lesson

In **Lesson 2.4: SF Symbols and Icons**, you'll learn how to work with Apple's icon system and create the `CategoryIcon` component for displaying category symbols with proper styling.

---

## Questions for Claude

When working through this lesson, you can ask:
- "How do I add animation when a card expands?"
- "What's the difference between @ViewBuilder and @escaping?"
- "How can I make the header stick to the top when scrolling?"
- "Can you explain the where clause syntax?"

Reference this lesson as: **"Lesson 2.3 - GlassCard"**
