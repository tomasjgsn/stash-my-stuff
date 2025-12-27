# Lesson 2.5: Custom Button Styles

> **Type**: Standard lesson (20-25 min)
> **Concepts**: NEW - ButtonStyle protocol, PrimitiveButtonStyle, Configuration pattern
> **Builds**: `DesignSystem/Styles/ButtonStyles.swift`, `DesignSystem/Components/FlagButton.swift`

---

## What You'll Learn

Buttons are everywhere in apps. In this lesson, you'll learn how SwiftUI's button styling system works and create custom styles for Stash My Stuff, including the crucial `FlagButton` for toggling item states.

---

## Prerequisites

Complete **Lessons 2.1-2.4** - you'll use tokens, modifiers, and icons.

---

## Part 1: Understanding Button Styles

### Default Button Behavior

```swift
Button("Tap Me") {
    print("Tapped!")
}
```

SwiftUI applies a default style based on context:
- iOS: Blue text that highlights on press
- macOS: Bordered button
- Forms: Row that highlights

### Built-in Styles

```swift
Button("Bordered") { }
    .buttonStyle(.bordered)

Button("Bordered Prominent") { }
    .buttonStyle(.borderedProminent)

Button("Borderless") { }
    .buttonStyle(.borderless)

Button("Plain") { }
    .buttonStyle(.plain)
```

### The ButtonStyle Protocol

To create custom styles, conform to `ButtonStyle`:

```swift
protocol ButtonStyle {
    associatedtype Body: View
    func makeBody(configuration: Configuration) -> Body
}
```

The `Configuration` gives you:
- `configuration.label` - The button's content (Text, Image, etc.)
- `configuration.isPressed` - Whether currently pressed
- `configuration.role` - Optional role (.destructive, .cancel)

---

## Part 2: Creating a Primary Button Style

Let's create a prominent, branded button style:

**File**: `StashMyStuff/DesignSystem/Styles/ButtonStyles.swift`

```swift
//
//  ButtonStyles.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Primary Button Style
/// A prominent filled button for primary actions
struct PrimaryButtonStyle: ButtonStyle {
    let color: Color

    init(color: Color = .accentColor) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(color)
            }
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extension
extension ButtonStyle where Self == PrimaryButtonStyle {
    /// Primary filled button style
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }

    /// Primary button with custom color
    static func primary(color: Color) -> PrimaryButtonStyle {
        PrimaryButtonStyle(color: color)
    }
}
```

**Usage:**

```swift
Button("Save Item") { }
    .buttonStyle(.primary)

Button("Delete") { }
    .buttonStyle(.primary(color: .red))
```

---

## Part 3: Secondary and Ghost Button Styles

Add more styles to the same file:

```swift
// MARK: - Secondary Button Style
/// A bordered button for secondary actions
struct SecondaryButtonStyle: ButtonStyle {
    let color: Color

    init(color: Color = .accentColor) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.headline)
            .foregroundStyle(color)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .stroke(color, lineWidth: 1.5)
            }
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static var secondary: SecondaryButtonStyle { SecondaryButtonStyle() }
    static func secondary(color: Color) -> SecondaryButtonStyle {
        SecondaryButtonStyle(color: color)
    }
}

// MARK: - Ghost Button Style
/// A minimal text-only button
struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.body)
            .foregroundStyle(configuration.isPressed ? .secondary : .primary)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GhostButtonStyle {
    static var ghost: GhostButtonStyle { GhostButtonStyle() }
}

// MARK: - Icon Button Style
/// A circular button for icon-only actions
struct IconButtonStyle: ButtonStyle {
    let size: CGFloat
    let backgroundColor: Color

    init(size: CGFloat = 44, backgroundColor: Color = .clear) {
        self.size = size
        self.backgroundColor = backgroundColor
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background {
                Circle()
                    .fill(backgroundColor)
            }
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == IconButtonStyle {
    static var icon: IconButtonStyle { IconButtonStyle() }
    static func icon(size: CGFloat, backgroundColor: Color = .clear) -> IconButtonStyle {
        IconButtonStyle(size: size, backgroundColor: backgroundColor)
    }
}
```

---

## Part 4: Glass Button Style

A button that matches our glass design language:

```swift
// MARK: - Glass Button Style
/// A button with native Liquid Glass effect
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.headline)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .glassEffect(
                .regular.interactive(),  // .interactive() handles press states automatically
                in: .rect(cornerRadius: DesignTokens.Glass.buttonRadius)
            )
            // Note: .interactive() handles opacity/scale press feedback automatically
            // No need for manual isPressed animations!
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle { GlassButtonStyle() }
}
```

**Key insight:** With `.glassEffect(.regular.interactive(), ...)`, the system handles press state feedback automatically. No need for manual opacity/scale animations — the Liquid Glass responds to touches natively.

---

## Part 5: Preview All Button Styles

```swift
// MARK: - Preview
#Preview("Button Styles") {
    ZStack {
        LinearGradient(
            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Primary buttons
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Primary Buttons")
                        .font(DesignTokens.Typography.headline)

                    HStack(spacing: DesignTokens.Spacing.md) {
                        Button("Default") { }
                            .buttonStyle(.primary)

                        Button("Custom") { }
                            .buttonStyle(.primary(color: .orange))

                        Button("Destructive") { }
                            .buttonStyle(.primary(color: .red))
                    }
                }

                Divider()

                // Secondary buttons
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Secondary Buttons")
                        .font(DesignTokens.Typography.headline)

                    HStack(spacing: DesignTokens.Spacing.md) {
                        Button("Default") { }
                            .buttonStyle(.secondary)

                        Button("Custom") { }
                            .buttonStyle(.secondary(color: .green))
                    }
                }

                Divider()

                // Other styles
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Text("Other Styles")
                        .font(DesignTokens.Typography.headline)

                    HStack(spacing: DesignTokens.Spacing.md) {
                        Button("Ghost") { }
                            .buttonStyle(.ghost)

                        Button("Glass") { }
                            .buttonStyle(.glass)

                        Button {
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                        .buttonStyle(.icon(size: 50, backgroundColor: .blue.opacity(0.2)))
                    }
                }
            }
            .padding()
        }
    }
}
```

---

## Part 6: Building the FlagButton Component

Now for the most important button in our app - the `FlagButton` for toggling item flags:

**File**: `StashMyStuff/DesignSystem/Components/FlagButton.swift`

```swift
//
//  FlagButton.swift
//  StashMyStuff
//

import SwiftUI

/// A toggleable button for item flags (cooked, read, watched, etc.)
struct FlagButton: View {
    let flag: FlagDefinition
    @Binding var isActive: Bool
    let onToggle: (() -> Void)?

    @State private var isAnimating = false

    init(
        flag: FlagDefinition,
        isActive: Binding<Bool>,
        onToggle: (() -> Void)? = nil
    ) {
        self.flag = flag
        self._isActive = isActive
        self.onToggle = onToggle
    }

    var body: some View {
        Button {
            // Trigger animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isActive.toggle()
                isAnimating = true
            }

            // Reset animation state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }

            onToggle?()
        } label: {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Image(systemName: isActive ? flag.icon : inactiveIcon)
                    .font(.system(size: 16, weight: .medium))
                    .symbolEffect(.bounce, value: isAnimating)

                Text(flag.label)
                    .font(DesignTokens.Typography.subheadline)
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .foregroundStyle(isActive ? .white : .primary)
            .background {
                Capsule()
                    .fill(isActive ? Color.accentColor : Color(.systemGray5))
            }
        }
        .buttonStyle(.plain)
    }

    /// Gets an outline version of the icon if available
    private var inactiveIcon: String {
        // Try to get unfilled version
        let filled = flag.icon
        if filled.hasSuffix(".fill") {
            return String(filled.dropLast(5)) // Remove ".fill"
        }
        return filled
    }
}

// MARK: - Preview
#Preview("FlagButton") {
    struct PreviewWrapper: View {
        @State private var cooked = false
        @State private var wouldCookAgain = true
        @State private var inBook = false

        var body: some View {
            let flags = CategoryConfig.config(for: .recipe)?.flags ?? []

            VStack(spacing: DesignTokens.Spacing.lg) {
                Text("Recipe Flags")
                    .font(DesignTokens.Typography.headline)

                if flags.count >= 3 {
                    VStack(spacing: DesignTokens.Spacing.md) {
                        FlagButton(flag: flags[0], isActive: $cooked)
                        FlagButton(flag: flags[1], isActive: $wouldCookAgain)
                        FlagButton(flag: flags[2], isActive: $inBook)
                    }
                }

                Divider()

                // Show all category flags
                ForEach(Category.allCases.prefix(3), id: \.self) { category in
                    if let config = CategoryConfig.config(for: category) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                            Text(category.rawValue)
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(.secondary)

                            FlowLayoutPreview {
                                ForEach(config.flags, id: \.key) { flag in
                                    FlagButtonPreview(flag: flag)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

// Helper for previews
private struct FlagButtonPreview: View {
    let flag: FlagDefinition
    @State private var isActive = false

    var body: some View {
        FlagButton(flag: flag, isActive: $isActive)
    }
}

// Simple flow layout for preview
private struct FlowLayoutPreview: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = flowLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func flowLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let spacing: CGFloat = 8
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

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
        }

        return (CGSize(width: maxWidth, height: currentY + lineHeight), positions)
    }
}
```

---

## Part 7: Compact Flag Button Variant

For tighter spaces, add a compact variant:

```swift
// MARK: - Compact Flag Button
/// A smaller, icon-only flag toggle
struct CompactFlagButton: View {
    let flag: FlagDefinition
    @Binding var isActive: Bool

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isActive.toggle()
            }
        } label: {
            Image(systemName: isActive ? flag.icon : inactiveIcon)
                .font(.system(size: 18))
                .foregroundStyle(isActive ? .accentColor : .secondary)
                .frame(width: 36, height: 36)
                .background {
                    Circle()
                        .fill(isActive ? Color.accentColor.opacity(0.15) : Color(.systemGray6))
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(flag.label)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    private var inactiveIcon: String {
        let filled = flag.icon
        if filled.hasSuffix(".fill") {
            return String(filled.dropLast(5))
        }
        return filled
    }
}

#Preview("Compact Flag Buttons") {
    struct PreviewWrapper: View {
        @State private var flags: [String: Bool] = [:]

        var body: some View {
            if let config = CategoryConfig.config(for: .movie) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(config.flags, id: \.key) { flag in
                        CompactFlagButton(
                            flag: flag,
                            isActive: Binding(
                                get: { flags[flag.key] ?? false },
                                set: { flags[flag.key] = $0 }
                            )
                        )
                    }
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}
```

---

## Part 8: Flag Row for Forms

A full-width flag toggle for settings/edit screens:

```swift
// MARK: - Flag Row
/// A full-width toggle row for editing screens
struct FlagRow: View {
    let flag: FlagDefinition
    @Binding var isActive: Bool

    var body: some View {
        Toggle(isOn: $isActive) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: flag.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isActive ? .accentColor : .secondary)
                    .frame(width: 24)

                Text(flag.label)
                    .font(DesignTokens.Typography.body)
            }
        }
        .toggleStyle(.switch)
    }
}

#Preview("Flag Row") {
    struct PreviewWrapper: View {
        @State private var flags: [String: Bool] = [:]

        var body: some View {
            Form {
                if let config = CategoryConfig.config(for: .book) {
                    Section("Book Flags") {
                        ForEach(config.flags, id: \.key) { flag in
                            FlagRow(
                                flag: flag,
                                isActive: Binding(
                                    get: { flags[flag.key] ?? false },
                                    set: { flags[flag.key] = $0 }
                                )
                            )
                        }
                    }
                }
            }
        }
    }

    return PreviewWrapper()
}
```

---

## Exercise: Your Turn

### Exercise 1: Create a Destructive Button Style

Create a button style specifically for delete/destructive actions with a red theme and confirmation shake animation.

<details>
<summary>Solution</summary>

```swift
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignTokens.Typography.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(Color.red)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == DestructiveButtonStyle {
    static var destructive: DestructiveButtonStyle { DestructiveButtonStyle() }
}
```

</details>

### Exercise 2: Create a Loading Button

Create a button style that shows a spinner when loading:

```swift
Button("Save") { }
    .buttonStyle(.loading(isLoading: isSaving))
```

<details>
<summary>Hint</summary>

Use `ProgressView()` and hide the label when loading.

</details>

---

## What You Built

Button styles and components in `DesignSystem/`:

**Styles/ButtonStyles.swift:**
- `PrimaryButtonStyle` - Filled prominent button
- `SecondaryButtonStyle` - Bordered button
- `GhostButtonStyle` - Text-only button
- `IconButtonStyle` - Circular icon button
- `GlassButtonStyle` - Glass morphism button

**Components/FlagButton.swift:**
- `FlagButton` - Full toggle with label
- `CompactFlagButton` - Icon-only toggle
- `FlagRow` - Form-style toggle row

---

## Key Concepts Learned

| Concept | What You Learned |
|---------|------------------|
| `ButtonStyle` protocol | Custom button appearance |
| `Configuration` | Access to label, isPressed, role |
| Static extensions | Clean `.buttonStyle(.primary)` syntax |
| `@Binding` | Two-way data flow for toggles |
| Symbol animation | `.symbolEffect(.bounce)` on state change |

---

## Usage Cheatsheet

```swift
// Button styles
Button("Primary") { }.buttonStyle(.primary)
Button("Secondary") { }.buttonStyle(.secondary)
Button("Glass") { }.buttonStyle(.glass)
Button { } label: { Image(systemName: "plus") }.buttonStyle(.icon)

// Flag buttons
FlagButton(flag: cookFlag, isActive: $isCooked)
CompactFlagButton(flag: cookFlag, isActive: $isCooked)
FlagRow(flag: cookFlag, isActive: $isCooked)  // For forms
```

---

## Next Lesson

In **Lesson 2.6: Building the Tag System**, you'll create the `TagChip` and `TagInput` components for managing item tags - a deep dive into more complex interactive components.

---

## Questions for Claude

When working through this lesson, you can ask:
- "How do I add haptic feedback to a button?"
- "What's the difference between ButtonStyle and PrimitiveButtonStyle?"
- "How can I disable a button style's press animation?"
- "Can I animate the background color on press?"

Reference this lesson as: **"Lesson 2.5 - Button Styles"**
