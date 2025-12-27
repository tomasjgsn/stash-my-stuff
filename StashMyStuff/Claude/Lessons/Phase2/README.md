# Phase 2: Design System & UI Components

> Build the Liquid Glass design system and reusable components before any screens.

---

## Overview

This phase teaches you to build a complete design system in SwiftUI. By the end, you'll have a library of reusable components that make building screens fast and consistent.

**Estimated Time**: 3-4 hours total (work at your own pace)

---

## Lessons

| # | Lesson | Type | Time | What You Build |
|---|--------|------|------|----------------|
| 2.1 | [Design Tokens](./Lesson-2.1-Design-Tokens.md) | Micro | 10-15 min | `DesignTokens.swift` - Colors, spacing, typography |
| 2.2 | [View Modifiers](./Lesson-2.2-View-Modifiers.md) | Standard | 20-30 min | Glass modifiers, category styling |
| 2.3 | [GlassCard Component](./Lesson-2.3-GlassCard-Component.md) | Standard | 25-30 min | `GlassCard.swift` - Flexible container |
| 2.4 | [SF Symbols & Icons](./Lesson-2.4-SF-Symbols-Icons.md) | Micro | 10-15 min | `CategoryIcon.swift`, `FlagIcon` |
| 2.5 | [Button Styles](./Lesson-2.5-Button-Styles.md) | Standard | 20-25 min | Button styles, `FlagButton.swift` |
| 2.6 | [Tag System](./Lesson-2.6-Tag-System.md) | Deep Dive | 40-50 min | `TagChip.swift`, `TagInput.swift`, FlowLayout |
| 2.7 | [List Row Components](./Lesson-2.7-List-Row-Components.md) | Standard | 25-30 min | `StashItemRow.swift`, `CategoryCard.swift` |
| 2.8 | [Animations & Haptics](./Lesson-2.8-Animations-Haptics.md) | Standard | 25-30 min | Animation presets, `HapticService.swift` |

---

## Learning Path

```
Lesson 2.1 ─────────────────────────────────────────────────┐
    │                                                        │
    ▼                                                        │
Lesson 2.2 (uses tokens)                                     │
    │                                                        │
    ▼                                                        │
Lesson 2.3 (uses modifiers)                                  │
    │                                                        │
    ├───────────┬───────────┐                                │
    ▼           ▼           ▼                                │
Lesson 2.4  Lesson 2.5  Lesson 2.6                           │
(icons)     (buttons)   (tags)                               │
    │           │           │                                │
    └───────────┴───────────┘                                │
                │                                            │
                ▼                                            │
         Lesson 2.7 (uses all above)                         │
                │                                            │
                ▼                                            │
         Lesson 2.8 (enhances all)◄──────────────────────────┘
                │
                ▼
         BOSS BATTLE
```

---

## File Structure After Completion

```
StashMyStuff/
└── DesignSystem/
    ├── DesignTokens.swift           (2.1)
    │
    ├── Modifiers/
    │   ├── GlassModifier.swift      (2.2)
    │   ├── CategoryModifier.swift   (2.2)
    │   └── ConditionalModifiers.swift (2.2)
    │
    ├── Styles/
    │   └── ButtonStyles.swift       (2.5)
    │
    ├── Components/
    │   ├── GlassCard.swift          (2.3)
    │   ├── CategoryIcon.swift       (2.4)
    │   ├── FlagButton.swift         (2.5)
    │   ├── TagChip.swift            (2.6)
    │   ├── TagInput.swift           (2.6)
    │   ├── ItemThumbnail.swift      (2.7)
    │   ├── StashItemRow.swift       (2.7)
    │   ├── CategoryCard.swift       (2.7)
    │   └── SmartViewRow.swift       (2.7)
    │
    ├── Utilities/
    │   └── AnimationPresets.swift   (2.8)
    │
    └── Services/
        └── HapticService.swift      (2.8)
```

---

## Concepts You'll Learn

### Swift Fundamentals (building on Phase 1)
- [x] Extensions (adding functionality to existing types)
- [x] Generics (`<Content: View>`)
- [ ] Protocol extensions

### SwiftUI
- [ ] View protocol
- [ ] @State
- [ ] @Binding
- [ ] @FocusState
- [ ] View modifiers (built-in and custom)
- [ ] ViewModifier protocol
- [ ] @ViewBuilder
- [ ] Layout protocol
- [ ] AsyncImage
- [ ] Animations and transitions

### Design Patterns
- [ ] Design tokens pattern
- [ ] Component composition
- [ ] Style configurations

---

## How to Work Through These Lessons

1. **Read the lesson** - Don't skim! The explanations matter.
2. **Create the files** - Type the code yourself (don't just copy-paste)
3. **Run the previews** - See your components in action
4. **Do the exercises** - Practice reinforces learning
5. **Ask Claude questions** - Reference the lesson by name

### Example Questions for Claude

After completing a lesson, you can ask:
- "In Lesson 2.3, why did we use `where Header == EmptyView`?"
- "Can you explain the FlowLayout from Lesson 2.6 in more detail?"
- "I'm stuck on the Exercise 2 in Lesson 2.5 - can you give me a hint?"

---

## Boss Battle

**Unlocks at**: 80% lesson completion (6+ lessons)
**Challenge**: Build a `RatingView` component

Requirements:
- Display 1-5 stars
- Support half-star ratings
- Animate on selection
- Provide haptic feedback
- Work in light and dark mode
- Include SwiftUI Preview

**Rules**:
- You can reference Apple documentation
- You can use components you built in the lessons
- You cannot ask Claude for implementation help (only requirement clarification)

---

## Tips for Success

### Take Your Time
These lessons build on each other. If something doesn't make sense, re-read it before moving on.

### Use Xcode Previews
Every component has previews. Use them to experiment and understand how changes affect the UI.

### Type the Code
Typing helps you internalize patterns. Copy-paste doesn't build muscle memory.

### Experiment
After completing a lesson, try modifying the code. What happens if you change the spring damping? What if you use a different color?

### Ask Questions
Keep notes of things that confuse you and ask Claude later. Reference the lesson name so Claude can give you context-specific help.

---

## Quick Reference

### Design Tokens
```swift
DesignTokens.Colors.categoryRecipe
DesignTokens.Glass.cardRadius            // 16pt
DesignTokens.Glass.buttonRadius          // 12pt
DesignTokens.Spacing.md
DesignTokens.Typography.headline
DesignTokens.Radius.lg
DesignTokens.Shadows.md                  // For non-glass elements
```

### Glass Effects (iOS 26+)
```swift
// Native Liquid Glass
view.glassEffect()
view.glassEffect(.regular, in: .rect(cornerRadius: 16))
view.glassEffect(.regular.interactive(), in: .capsule)  // For buttons
```

### Modifiers
```swift
.glassCard()                             // Native Liquid Glass card
.glassCard(cornerRadius: 20)             // Custom corner radius
.glassButton()                           // Interactive glass for buttons
.categoryAccent(.recipe)
.categoryBadge(.book)
.if(condition) { view in view.modifier() }
```

### Components
```swift
GlassCard { content }
GlassCard(isInteractive: true) { content }  // For tappable cards
CategoryIcon(.recipe, size: .large, style: .filled)
FlagButton(flag: definition, isActive: $isActive)
TagChip("vegetarian", onRemove: { })
TagInput(tags: $tags, suggestions: suggestions)
StashItemRow(item: item, style: .standard)
CategoryCard(.recipe, itemCount: 12, style: .grid)
```

### Animations
```swift
.animation(.quick, value: x)
.animation(.bouncy, value: x)
withAnimation(.standard) { state = newValue }
.transition(.slideUp)
```

### Haptics
```swift
HapticService.shared.buttonTapped()
HapticService.shared.success()
HapticService.shared.flagToggled(isNowActive: true)
```

---

## Next Phase

After completing Phase 2 and the Boss Battle, you'll move to **Phase 3: Core App Screens** where you'll use all these components to build the actual app UI.

---

*Good luck! You've got this.*
