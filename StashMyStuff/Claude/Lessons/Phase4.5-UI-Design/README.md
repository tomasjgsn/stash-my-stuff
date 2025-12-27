# Phase 4.5: Custom UI Design with Figma

> Transform Stash My Stuff from functional to distinctive with a professional UI redesign.

---

## Overview

After completing the Share Extension (Phase 4), you'll take a step back from code to focus on **visual design**. This phase teaches you to use Figma to create a sophisticated, distinctive UI inspired by top agencies like [Ragged Edge](https://raggededge.com/).

**Goal**: Design a refined visual identity that elevates Stash My Stuff from "good enough" to "delightfully memorable."

**Estimated Time**: 8-12 hours across multiple sessions

---

## Why This Phase Exists

Most developer-designed apps look... like developer-designed apps. They're functional but forgettable. This phase bridges the gap between:

- **Phase 2** (Basic design tokens and components)
- **Phase 6** (Polish and App Store prep)

By designing in Figma first, you can:
1. Experiment freely without rewriting code
2. See the entire app holistically
3. Make bold decisions you might avoid in code
4. Create assets for App Store screenshots

---

## Design Inspiration: The Ragged Edge Approach

[Ragged Edge](https://raggededge.com/) is a London-based branding agency known for:

### Visual Principles
| Principle | Description | How to Apply |
|-----------|-------------|--------------|
| **Restrained Elegance** | Generous whitespace, no clutter | Increase padding, reduce visual noise |
| **Custom Typography** | Distinctive but readable fonts | Use SF Pro Rounded + one accent font |
| **Warm Color Palette** | Move beyond pure system colors | Add warmth with tinted neutrals |
| **Grid Discipline** | Consistent modular layouts | 8pt grid, consistent card sizes |
| **Meaningful Motion** | Animation that clarifies, not decorates | Purpose-driven micro-interactions |
| **Data as Story** | Numbers that matter | "12 uncooked" not just "12 items" |

### What Makes It Distinctive
- Avoids clichĂ© "tech app" aesthetics
- Every element earns its place
- Photography/imagery feels curated, not stock
- Typography creates hierarchy without shouting

---

## Figma Free Plan Strategy

Figma's free tier has limitations, but we can work within them:

### Free Plan Limits
- 3 Figma files maximum
- Unlimited drafts (personal only)
- Basic prototyping
- No team libraries

### Our 3-File Strategy

| File | Purpose | Contents |
|------|---------|----------|
| **1. Design System** | Reusable components | Colors, typography, icons, components |
| **2. iOS Screens** | Main app designs | All iPhone/iPad screens |
| **3. Prototype** | Interactive demo | Key user flows connected |

This structure maximizes value from your 3 files.

---

## Lessons

| # | Lesson | Type | Time | What You Create |
|---|--------|------|------|-----------------|
| 4.5.1 | [Figma Fundamentals](./Lesson-4.5.1-Figma-Fundamentals.md) | Standard | 45 min | Figma account, workspace setup |
| 4.5.2 | [Design System File](./Lesson-4.5.2-Design-System-File.md) | Deep Dive | 90 min | Complete component library |
| 4.5.3 | [Typography & Color Refinement](./Lesson-4.5.3-Typography-Color.md) | Standard | 60 min | Polished type scale, color palette |
| 4.5.4 | [Home Screen Design](./Lesson-4.5.4-Home-Screen.md) | Standard | 60 min | Redesigned home screen |
| 4.5.5 | [Category & Detail Screens](./Lesson-4.5.5-Category-Detail.md) | Deep Dive | 90 min | Full screen set |
| 4.5.6 | [Prototyping & Handoff](./Lesson-4.5.6-Prototyping.md) | Standard | 45 min | Interactive prototype, specs |

---

## What You'll Learn

### Figma Skills
- [ ] Frame and Auto Layout basics
- [ ] Creating and using components
- [ ] Variants for state management
- [ ] Basic prototyping and transitions
- [ ] Exporting assets for Xcode
- [ ] Extracting specs for SwiftUI

### Design Thinking
- [ ] Visual hierarchy principles
- [ ] Color theory for UI
- [ ] Typography pairing
- [ ] Whitespace as a design tool
- [ ] Motion design principles
- [ ] Designing for accessibility

---

## Phase 4.5 Deliverables

By the end of this phase, you'll have:

### 1. Design System File
```
📁 Stash My Stuff - Design System
├── 🎨 Colors
│   ├── Primary palette
│   ├── Category colors (refined)
│   ├── Semantic colors
│   └── Dark mode variants
├── 📝 Typography
│   ├── Type scale
│   ├── Font pairings
│   └── Text styles
├── 📐 Spacing & Layout
│   ├── Grid system
│   └── Spacing tokens
└── 🧩 Components
    ├── Buttons (all states)
    ├── Cards (glass variants)
    ├── List rows
    ├── Navigation elements
    ├── Tag chips
    ├── Flag buttons
    └── Form elements
```

### 2. iOS Screens File
```
📁 Stash My Stuff - iOS Screens
├── 📱 Home
│   ├── Default state
│   ├── With items
│   └── Empty state
├── 📋 Category List
│   ├── Grid view
│   ├── List view
│   └── Filtered states
├── 📄 Item Detail
│   ├── With image
│   ├── Without image
│   └── Edit mode
├── ➕ Add Item
│   ├── Manual entry
│   └── From share
├── ⚙️ Settings
└── 🔍 Search
```

### 3. Prototype File
```
📁 Stash My Stuff - Prototype
├── 🎬 Flow 1: Browse & View
│   └── Home → Category → Detail → Back
├── 🎬 Flow 2: Add Item
│   └── Home → Add → Category Select → Save → List
└── 🎬 Flow 3: Quick Actions
    └── List → Swipe → Delete/Favorite
```

---

## Design Goals

### Before (Phase 2 System)
- System colors (blue, orange, etc.)
- Standard SF Pro
- Functional but generic
- "Works fine" aesthetic

### After (Phase 4.5 Redesign)
- Refined, warm color palette
- SF Pro Rounded + custom accents
- Distinctive and memorable
- "This feels premium" aesthetic

---

## Visual Direction

Based on Ragged Edge's approach, our redesign will focus on:

### 1. Warm Sophistication
Replace pure system colors with tinted, warmer variants:
- Pure white → Cream/warm white
- System gray → Warm gray
- Harsh shadows → Soft, tinted shadows

### 2. Typography with Personality
- **Primary**: SF Pro Rounded (approachable, modern)
- **Accent**: Consider a distinctive display font for titles
- **Hierarchy**: Clear size/weight progression

### 3. Generous Spacing
- Increase padding by 20-30%
- Let elements breathe
- Use whitespace to guide the eye

### 4. Purposeful Motion
- Every animation should have a reason
- Micro-interactions for feedback
- Transitions that maintain context

### 5. Curated Details
- Custom icons where SF Symbols feel generic
- Subtle textures or patterns
- Consistent illustration style if used

---

## Figma Resources

### Learning
- [Figma for Beginners (YouTube)](https://www.youtube.com/playlist?list=PLXDU_eVOJTx7QHLShNqIXL1Cgbxj7HlN4)
- [Figma Learn (Official)](https://help.figma.com/hc/en-us/categories/360002051613-Figma-design)
- [Auto Layout Crash Course](https://www.youtube.com/watch?v=TyaGpGDFczw)

### Inspiration
- [Mobbin](https://mobbin.com/) - Real app screenshots
- [Dribbble iOS](https://dribbble.com/tags/ios) - Design inspiration
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Assets
- [SF Symbols](https://developer.apple.com/sf-symbols/) - Apple's icon set
- [Unsplash](https://unsplash.com/) - Free photos
- [Figma Community](https://www.figma.com/community) - Free templates

---

## Integration with SwiftUI

After designing in Figma, you'll extract:

### Colors
```swift
// Export from Figma as hex values
extension DesignTokens.Colors {
    static let warmBackground = Color(hex: "FBF9F7")
    static let softShadow = Color(hex: "1A1A1A").opacity(0.08)
}
```

### Spacing
```swift
// Match Figma measurements
extension DesignTokens.Spacing {
    static let cardPadding: CGFloat = 20  // From Figma
    static let sectionGap: CGFloat = 32   // From Figma
}
```

### Assets
- Export icons as PDF (vector) or PNG @1x, @2x, @3x
- Add to Xcode Asset Catalog
- Use in SwiftUI: `Image("custom-icon")`

---

## Success Criteria

- [ ] Design system file is complete and organized
- [ ] All core screens are designed
- [ ] Prototype demonstrates 3 key flows
- [ ] Design works in light and dark mode
- [ ] Colors pass accessibility contrast checks
- [ ] You can articulate *why* each design decision was made

---

## Timeline Suggestion

| Session | Focus | Duration |
|---------|-------|----------|
| 1 | Figma setup, design system start | 2 hours |
| 2 | Complete design system | 2 hours |
| 3 | Home and category screens | 2 hours |
| 4 | Detail and add screens | 2 hours |
| 5 | Polish and prototype | 2 hours |
| 6 | Export assets, update SwiftUI | 2 hours |

---

## Next Steps

After completing Phase 4.5:
1. Export assets and add to Xcode
2. Update `DesignTokens.swift` with refined values
3. Update components with new styling
4. Move to Phase 5: CloudKit Sync

---

## Questions for Claude

When working through this phase, you can ask:
- "How do I create a component with variants in Figma?"
- "Can you help me pick a color palette that feels warmer?"
- "How do I export this Figma design as SwiftUI code?"
- "What's the best way to organize my Figma layers?"

Reference this phase as: **"Phase 4.5 - UI Design"**

---

## Sources & Inspiration

- [Ragged Edge](https://raggededge.com/) - Design agency inspiration
- [Creative Boom - Ragged Edge Rebrand](https://www.creativeboom.com/insight/ragged-edge-redraws-the-horizon-with-never-be-the-same-again/)
- [Figma Pricing & Features](https://www.figma.com/pricing/)
- [Figma Free Plan Limitations](https://www.wadeswatch.com/limitations-of-free-figma/)
