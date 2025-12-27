# Lesson 2.8: Animations and Haptics

> **Type**: Standard lesson (25-30 min)
> **Concepts**: NEW - Spring animations, transitions, matchedGeometryEffect, UIImpactFeedbackGenerator
> **Builds**: `DesignSystem/Services/HapticService.swift`, animation utilities

---

## What You'll Learn

Animations and haptics add delight and clarity to your app. In this lesson, you'll learn SwiftUI's animation system and create a haptic feedback service for Stash My Stuff.

---

## Prerequisites

Complete **Lessons 2.1-2.7** - you'll enhance previously built components.

---

## Part 1: Understanding SwiftUI Animations

### Implicit vs Explicit Animations

**Implicit**: Animate any change to a value
```swift
Text("Hello")
    .scaleEffect(isLarge ? 1.5 : 1.0)
    .animation(.spring(), value: isLarge)  // Animates when isLarge changes
```

**Explicit**: Wrap state changes in withAnimation
```swift
Button("Toggle") {
    withAnimation(.spring()) {
        isLarge.toggle()  // All views depending on isLarge animate
    }
}
```

### Animation Types

```swift
// Linear - constant speed
.animation(.linear(duration: 0.3), value: x)

// Ease in/out - natural acceleration
.animation(.easeInOut(duration: 0.3), value: x)

// Spring - bouncy, physical feel
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: x)

// Bouncy preset (iOS 17+)
.animation(.bouncy, value: x)

// Smooth preset (iOS 17+)
.animation(.smooth, value: x)
```

### Spring Parameters

```swift
.spring(
    response: 0.3,        // Duration-like (higher = slower)
    dampingFraction: 0.6, // Bounciness (0 = forever, 1 = no bounce)
    blendDuration: 0      // Smoothing when interrupted
)
```

| Damping | Feel |
|---------|------|
| 0.3 | Very bouncy |
| 0.5 | Bouncy |
| 0.7 | Slight bounce |
| 1.0 | No bounce (critical damping) |

---

## Part 2: Animation Presets for the App

Let's create standard animation presets:

**File**: `StashMyStuff/DesignSystem/Utilities/AnimationPresets.swift`

```swift
//
//  AnimationPresets.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Animation Presets
extension Animation {
    /// Quick response for button presses, toggles
    static let quick = Animation.spring(response: 0.2, dampingFraction: 0.7)

    /// Standard interaction animation
    static let standard = Animation.spring(response: 0.3, dampingFraction: 0.7)

    /// Bouncy animation for celebratory moments
    static let bouncy = Animation.spring(response: 0.4, dampingFraction: 0.5)

    /// Smooth animation for subtle changes
    static let smooth = Animation.spring(response: 0.4, dampingFraction: 1.0)

    /// Slow reveal for larger transitions
    static let reveal = Animation.spring(response: 0.5, dampingFraction: 0.8)
}

// MARK: - Transition Presets
extension AnyTransition {
    /// Slide in from bottom with fade
    static let slideUp = AnyTransition.asymmetric(
        insertion: .move(edge: .bottom).combined(with: .opacity),
        removal: .move(edge: .bottom).combined(with: .opacity)
    )

    /// Scale in from center
    static let pop = AnyTransition.scale(scale: 0.8).combined(with: .opacity)

    /// Slide from trailing edge
    static let slideIn = AnyTransition.move(edge: .trailing).combined(with: .opacity)
}

// MARK: - View Extension for Common Animations
extension View {
    /// Applies a press effect that scales down when pressed
    func pressEffect(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.quick, value: isPressed)
    }

    /// Adds a shake animation (for errors)
    func shake(trigger: Bool) -> some View {
        self.modifier(ShakeModifier(trigger: trigger))
    }

    /// Adds a pulse animation
    func pulse(isActive: Bool) -> some View {
        self.modifier(PulseModifier(isActive: isActive))
    }
}

// MARK: - Shake Modifier
struct ShakeModifier: ViewModifier {
    let trigger: Bool
    @State private var shakeOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: shakeOffset)
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    withAnimation(.linear(duration: 0.05)) {
                        shakeOffset = 10
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.linear(duration: 0.05)) {
                            shakeOffset = -10
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.linear(duration: 0.05)) {
                            shakeOffset = 5
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.linear(duration: 0.05)) {
                            shakeOffset = 0
                        }
                    }
                }
            }
    }
}

// MARK: - Pulse Modifier
struct PulseModifier: ViewModifier {
    let isActive: Bool
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .onAppear {
                guard isActive else { return }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        isPulsing = true
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isPulsing = false
                    }
                }
            }
    }
}

// MARK: - Preview
#Preview("Animation Presets") {
    struct PreviewWrapper: View {
        @State private var isToggled = false
        @State private var showError = false

        var body: some View {
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Spring animations comparison
                HStack(spacing: DesignTokens.Spacing.lg) {
                    VStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 50, height: 50)
                            .scaleEffect(isToggled ? 1.3 : 1.0)
                            .animation(.quick, value: isToggled)
                        Text("Quick")
                            .font(.caption)
                    }

                    VStack {
                        Circle()
                            .fill(.green)
                            .frame(width: 50, height: 50)
                            .scaleEffect(isToggled ? 1.3 : 1.0)
                            .animation(.bouncy, value: isToggled)
                        Text("Bouncy")
                            .font(.caption)
                    }

                    VStack {
                        Circle()
                            .fill(.purple)
                            .frame(width: 50, height: 50)
                            .scaleEffect(isToggled ? 1.3 : 1.0)
                            .animation(.smooth, value: isToggled)
                        Text("Smooth")
                            .font(.caption)
                    }
                }

                Button("Toggle") {
                    isToggled.toggle()
                }
                .buttonStyle(.primary)

                Divider()

                // Shake effect
                Text("Shake Me!")
                    .font(.headline)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shake(trigger: showError)

                Button("Trigger Shake") {
                    showError.toggle()
                }

                Divider()

                // Pulse effect
                Circle()
                    .fill(.orange)
                    .frame(width: 60, height: 60)
                    .pulse(isActive: isToggled)

                Text("Toggle to pulse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
```

---

## Part 3: Transitions

Transitions control how views appear and disappear:

```swift
// Basic usage
if showDetail {
    DetailView()
        .transition(.slideUp)
}

// The if must be inside withAnimation
Button("Show") {
    withAnimation(.standard) {
        showDetail = true
    }
}
```

### Custom Transition Example

```swift
extension AnyTransition {
    static var cardAppear: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9)
                .combined(with: .opacity)
                .combined(with: .offset(y: 20)),
            removal: .scale(scale: 0.9)
                .combined(with: .opacity)
        )
    }
}
```

---

## Part 4: Haptic Feedback Service

Haptics provide tactile feedback that makes the app feel responsive:

**File**: `StashMyStuff/DesignSystem/Services/HapticService.swift`

```swift
//
//  HapticService.swift
//  StashMyStuff
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Provides haptic feedback for user interactions
@MainActor
final class HapticService {
    static let shared = HapticService()

    private init() {}

    // MARK: - Impact Feedback

    /// Light impact - subtle feedback for small UI changes
    func lightImpact() {
        #if canImport(UIKit) && !os(macOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }

    /// Medium impact - standard button presses, toggles
    func mediumImpact() {
        #if canImport(UIKit) && !os(macOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }

    /// Heavy impact - significant actions, confirmations
    func heavyImpact() {
        #if canImport(UIKit) && !os(macOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }

    /// Soft impact - gentle, cushioned feel
    func softImpact() {
        #if canImport(UIKit) && !os(macOS)
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        #endif
    }

    /// Rigid impact - sharp, precise feel
    func rigidImpact() {
        #if canImport(UIKit) && !os(macOS)
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
        #endif
    }

    // MARK: - Notification Feedback

    /// Success - task completed successfully
    func success() {
        #if canImport(UIKit) && !os(macOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    /// Warning - caution needed
    func warning() {
        #if canImport(UIKit) && !os(macOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }

    /// Error - something went wrong
    func error() {
        #if canImport(UIKit) && !os(macOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }

    // MARK: - Selection Feedback

    /// Selection changed - for pickers, toggles
    func selectionChanged() {
        #if canImport(UIKit) && !os(macOS)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }

    // MARK: - Semantic Haptics (Convenience)

    /// Flag toggled on/off
    func flagToggled(isNowActive: Bool) {
        if isNowActive {
            mediumImpact()
        } else {
            lightImpact()
        }
    }

    /// Item saved successfully
    func itemSaved() {
        success()
    }

    /// Item deleted
    func itemDeleted() {
        rigidImpact()
    }

    /// Favorite toggled
    func favoriteToggled(isFavorite: Bool) {
        if isFavorite {
            // Double tap feeling for adding favorite
            lightImpact()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.lightImpact()
            }
        } else {
            lightImpact()
        }
    }

    /// Pull to refresh triggered
    func pullToRefresh() {
        mediumImpact()
    }

    /// Button pressed
    func buttonTapped() {
        lightImpact()
    }
}

// MARK: - View Extension
extension View {
    /// Adds haptic feedback on tap
    func hapticOnTap(_ feedback: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                feedback()
            }
        )
    }
}
```

---

## Part 5: Animated Flag Button Update

Let's enhance the `FlagButton` with animations and haptics:

Add to or update `FlagButton.swift`:

```swift
// MARK: - Animated Flag Button
struct AnimatedFlagButton: View {
    let flag: FlagDefinition
    @Binding var isActive: Bool

    @State private var isAnimating = false

    var body: some View {
        Button {
            // Haptic feedback
            HapticService.shared.flagToggled(isNowActive: !isActive)

            // Animate
            withAnimation(.bouncy) {
                isActive.toggle()
                isAnimating = true
            }

            // Reset animation state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
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
            .scaleEffect(isAnimating ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private var inactiveIcon: String {
        flag.icon.hasSuffix(".fill") ? String(flag.icon.dropLast(5)) : flag.icon
    }
}
```

---

## Part 6: Animated List Operations

Add animations for list changes:

```swift
// MARK: - Animated List Helpers
extension View {
    /// Standard animation for list item operations
    func listItemAnimation() -> some View {
        self
            .transition(.asymmetric(
                insertion: .scale(scale: 0.9).combined(with: .opacity),
                removal: .scale(scale: 0.9).combined(with: .opacity)
            ))
    }
}

// Usage in a list:
// ForEach(items) { item in
//     StashItemRow(item: item)
//         .listItemAnimation()
// }
```

---

## Part 7: Loading State Animation

A reusable loading indicator:

```swift
// MARK: - Loading Indicator
struct LoadingIndicator: View {
    let message: String?
    @State private var isAnimating = false

    init(_ message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Animated dots
            HStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 10, height: 10)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }

            if let message {
                Text(message)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview("LoadingIndicator") {
    VStack(spacing: DesignTokens.Spacing.xl) {
        LoadingIndicator()
        LoadingIndicator("Saving...")
        LoadingIndicator("Syncing with iCloud")
    }
}
```

---

## Part 8: Success Checkmark Animation

For completed actions:

```swift
// MARK: - Success Checkmark
struct SuccessCheckmark: View {
    @State private var isVisible = false
    @State private var checkmarkScale: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(.green)
                .frame(width: 60, height: 60)
                .scaleEffect(isVisible ? 1.0 : 0.0)

            Image(systemName: "checkmark")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .scaleEffect(checkmarkScale)
        }
        .onAppear {
            // Haptic
            HapticService.shared.success()

            // Circle appears
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isVisible = true
            }

            // Checkmark bounces in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.1)) {
                checkmarkScale = 1.0
            }
        }
    }
}

#Preview("SuccessCheckmark") {
    SuccessCheckmark()
}
```

---

## Part 9: Complete Animation Example

Putting it all together in a realistic scenario:

```swift
#Preview("Complete Animation Demo") {
    struct DemoView: View {
        @State private var items = ["Item 1", "Item 2", "Item 3"]
        @State private var showSuccess = false
        @State private var isLoading = false

        var body: some View {
            NavigationStack {
                ZStack {
                    List {
                        ForEach(items, id: \.self) { item in
                            Text(item)
                                .listItemAnimation()
                        }
                        .onDelete { indexSet in
                            withAnimation(.standard) {
                                items.remove(atOffsets: indexSet)
                            }
                            HapticService.shared.itemDeleted()
                        }
                    }
                    .navigationTitle("Demo")
                    .toolbar {
                        Button {
                            addItem()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }

                    // Loading overlay
                    if isLoading {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .transition(.opacity)

                        LoadingIndicator("Adding item...")
                            .padding()
                            .glassEffect(.regular, in: .rect(cornerRadius: 12))
                    }

                    // Success overlay
                    if showSuccess {
                        SuccessCheckmark()
                    }
                }
            }
        }

        func addItem() {
            HapticService.shared.buttonTapped()

            withAnimation(.standard) {
                isLoading = true
            }

            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.standard) {
                    isLoading = false
                    items.append("Item \(items.count + 1)")
                    showSuccess = true
                }

                // Hide success after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.smooth) {
                        showSuccess = false
                    }
                }
            }
        }
    }

    return DemoView()
}
```

---

## Exercise: Your Turn

### Exercise 1: Favorite Heart Animation

Create an animated heart that bursts into particles when favoriting:

<details>
<summary>Hint</summary>

Use multiple scaled/offset circles that animate outward with opacity fade.

</details>

### Exercise 2: Category Selection Animation

Create a picker where the selected category smoothly scales up while others scale down:

```swift
CategoryPicker(selected: $category)
```

---

## What You Built

Animation and haptic utilities:

**Utilities/AnimationPresets.swift:**
- Standard animation presets (`.quick`, `.bouncy`, `.smooth`)
- Transition presets (`.slideUp`, `.pop`)
- Shake and pulse modifiers

**Services/HapticService.swift:**
- Centralized haptic feedback
- Semantic methods (`flagToggled`, `itemSaved`, etc.)
- Platform-safe implementation

**Components updates:**
- `AnimatedFlagButton` with haptics
- `LoadingIndicator` with animated dots
- `SuccessCheckmark` with bounce effect

---

## Key Concepts Learned

| Concept | What You Learned |
|---------|------------------|
| Spring animations | Response, damping, and feel |
| Transitions | How views enter/exit |
| Haptic feedback | UIKit feedback generators |
| Coordinated animations | Multiple animated properties |
| State-driven animation | Triggering with @State |

---

## Animation Quick Reference

```swift
// Presets
.animation(.quick, value: x)     // Fast response
.animation(.bouncy, value: x)    // Playful
.animation(.smooth, value: x)    // Subtle
.animation(.reveal, value: x)    // Slow reveal

// Explicit
withAnimation(.bouncy) {
    isExpanded = true
}

// Transitions
if isVisible {
    ContentView()
        .transition(.slideUp)
}

// Haptics
HapticService.shared.buttonTapped()
HapticService.shared.success()
HapticService.shared.error()
```

---

## Phase 2 Complete!

Congratulations! You've built a complete design system for Stash My Stuff:

1. **Design Tokens** - Colors, spacing, typography, radii, shadows
2. **View Modifiers** - Glass effects, category styling
3. **GlassCard** - Flexible container component
4. **SF Symbols** - CategoryIcon, FlagIcon
5. **Button Styles** - Primary, secondary, glass, icon
6. **Tag System** - TagChip, TagInput with autocomplete
7. **List Components** - StashItemRow, CategoryCard, SmartViewRow
8. **Animations & Haptics** - Presets and feedback service

---

## Boss Battle: Unlocked!

You're ready for the Phase 2 Boss Battle. See `PROGRESS.md` for the challenge:

**Build a complete `RatingView` component that:**
- Displays 1-5 stars with half-star support
- Animates on selection
- Provides haptic feedback
- Works in both light and dark mode

Good luck!

---

## Questions for Claude

When working through this lesson, you can ask:
- "How do I create a continuous rotation animation?"
- "What's matchedGeometryEffect and when should I use it?"
- "How do I chain multiple animations in sequence?"
- "Can you explain the timing of DispatchQueue.main.asyncAfter?"

Reference this lesson as: **"Lesson 2.8 - Animations & Haptics"**
