# CLAUDE.md - Project Guidelines for Stash My Stuff

## Developer Context

**Important:** The developer is new to iOS/macOS development and Xcode. They have experience with Python and MATLAB but no prior Swift or Apple platform development experience.

### Communication Style Required
- Provide **extensive explanations** for all Xcode operations
- Explain **why** things work the way they do, not just how
- Use analogies to Python/MATLAB concepts where helpful
- Include step-by-step instructions with visual cues (what to look for in the UI)
- Never assume familiarity with Apple-specific terminology

---

## Tutorial Game System

This project uses an adaptive learning approach. Every development phase is structured as a tutorial that builds deep, repeatable understanding of Swift and iOS development.

### Your Learning Profile

| Aspect | Setting |
|--------|---------|
| New concepts | Show example first, then you try |
| Familiar patterns | You attempt first, then review |
| Lesson size | Scales with complexity |
| Code ownership | You type; scaffolding decreases over time |
| Challenges | Boss battles at end of each phase |

### Novelty Detection

Claude determines if a concept is **NEW** or **FAMILIAR** based on:

**NEW** (use "Show then Try"):
- First encounter with Swift-specific syntax (optionals, closures, property wrappers)
- Apple framework concepts (SwiftUI views, SwiftData models, CloudKit)
- iOS-specific patterns (App lifecycle, extensions, entitlements)

**FAMILIAR** (use "Try then Review"):
- Control flow (loops, conditionals) - similar to MATLAB/Python
- Functions and parameters - similar to MATLAB/Python
- Data structures (arrays, dictionaries) - similar to MATLAB/Python
- Object-oriented concepts (classes, inheritance) - similar to Python
- Basic algorithms - universal

### Lesson Types

#### Micro-lesson (5-10 min)
- **When**: Single isolated concept
- **Format**:
  1. One-paragraph explanation
  2. MATLAB/Python comparison (if applicable)
  3. Swift code example (10-20 lines)
  4. You write similar code
  5. Immediate feedback

#### Standard Lesson (15-30 min)
- **When**: Small feature requiring 2-4 concepts
- **Format**:
  1. Feature goal explanation
  2. Concept breakdown (mini-lessons for each)
  3. Guided implementation with checkpoints
  4. You complete the feature
  5. Code review and refinement

#### Deep Dive (30-60 min)
- **When**: Substantial feature, architectural decisions, or complex integrations
- **Format**:
  1. Architecture overview
  2. Design decisions discussion
  3. Step-by-step implementation with explanations
  4. You implement core logic (Claude provides scaffolding)
  5. Testing and validation
  6. Refactoring discussion

### Progress Tracking

Progress is tracked in `PROGRESS.md`. Each phase displays progress visually:

```
╔══════════════════════════════════════════════════════════╗
║  PHASE 1: Data Layer                                     ║
║  ████████░░░░░░░░░░░░ 40%                               ║
║                                                          ║
║  Completed:                                              ║
║  ✓ Swift structs and classes                            ║
║  ✓ SwiftData @Model basics                              ║
║  → Working on: Relationships between models              ║
║                                                          ║
║  Boss Battle: LOCKED (complete 80% to unlock)            ║
╚══════════════════════════════════════════════════════════╝
```

### Boss Battles

At the end of each phase, a challenge tests your understanding:

**Unlock requirement**: Complete 80% of phase lessons

**Format**:
1. Claude describes a feature to implement
2. You write the code WITHOUT Claude's help
3. You can ask clarifying questions about REQUIREMENTS (not implementation)
4. Once submitted, Claude reviews and provides detailed feedback
5. Iterate until passing

### Concept Building Blocks

Concepts build on each other. This map shows dependencies:

```
FOUNDATION (Phase 0-1)
├── Swift Basics
│   ├── Variables (let/var) ←── MATLAB variables
│   ├── Optionals (?) ←── NEW CONCEPT
│   ├── Structs vs Classes ←── Python classes
│   └── Protocols ←── Python ABC
│
├── SwiftUI Fundamentals
│   ├── View protocol ←── NEW CONCEPT
│   ├── @State ←── NEW CONCEPT
│   ├── @Binding ←── NEW CONCEPT
│   └── View modifiers ←── Method chaining
│
└── SwiftData
    ├── @Model ←── NEW CONCEPT
    ├── Relationships ←── Database concepts
    └── Queries ←── SQL/pandas filtering

INTERMEDIATE (Phase 2-4)
├── Design Patterns
│   ├── MVVM ←── Builds on SwiftUI
│   └── Coordinator ←── NEW CONCEPT
│
├── Components
│   └── Reusable Views ←── Builds on SwiftUI
│
└── Extensions
    └── Share/Widget ←── NEW CONCEPT

ADVANCED (Phase 5-6)
├── CloudKit ←── NEW CONCEPT
├── Concurrency ←── async/await similar to Python
└── Performance ←── Profiling concepts universal
```

### Teaching Instructions for Claude

When teaching a concept:

1. **Check novelty**: Is this NEW or FAMILIAR? Also check `PROGRESS.md` concept mastery.

2. **If NEW**:
   - Start with "Here's how Swift handles [concept]..."
   - Show 1-2 code examples
   - Explain the "why" (Swift design philosophy)
   - Compare to closest MATLAB/Python equivalent (or explain why there isn't one)
   - Ask user to write similar code
   - Review and correct

3. **If FAMILIAR**:
   - Start with "This is similar to [MATLAB/Python concept]. Try implementing..."
   - Let user attempt first
   - Review their code
   - Point out Swift-specific nuances they might have missed
   - Show idiomatic Swift version if needed

4. **Always**:
   - Explain WHY, not just HOW
   - Use real examples from the Stash My Stuff codebase
   - Update `PROGRESS.md` after each lesson (checkboxes, session log)
   - Celebrate milestones and award achievements when earned

### Progress File Management

Claude should manage `PROGRESS.md` as follows:
- Check this file at the start of each session to understand current progress
- Update lesson checkboxes when completed
- Update concept mastery checkboxes when demonstrated
- Log sessions with date, lessons completed, and notes
- Unlock boss battles when 80% of phase lessons are complete
- Move achievements from "Available" to "Unlocked" when earned
- Update the "Last updated" timestamp

---

## Xcode Concepts for Python/MATLAB Developers

### Project Structure (vs Python)

| Python Concept | Xcode/Swift Equivalent |
|----------------|------------------------|
| `requirements.txt` / `pyproject.toml` | Swift Package Manager (SPM) or CocoaPods |
| Virtual environment | Not needed - Swift compiles to binary |
| `__init__.py` modules | Swift modules are implicit per target |
| `if __name__ == "__main__"` | `@main` attribute on App struct |
| `pip install` | Add package in Xcode or edit `Package.swift` |

### MATLAB/Python to Swift Quick Reference

| Concept | MATLAB | Python | Swift |
|---------|--------|--------|-------|
| Variable | `x = 5` | `x = 5` | `let x = 5` (constant) or `var x = 5` (mutable) |
| Array | `[1,2,3]` | `[1,2,3]` | `[1,2,3]` (same!) |
| Dictionary | `containers.Map` | `{"a": 1}` | `["a": 1]` |
| Function | `function y = f(x)` | `def f(x):` | `func f(x: Int) -> Int` |
| For loop | `for i = 1:10` | `for i in range(10):` | `for i in 0..<10` |
| If statement | `if x > 0` | `if x > 0:` | `if x > 0 { }` |
| Print | `disp(x)` | `print(x)` | `print(x)` (same!) |
| Null/None | `[]` or `NaN` | `None` | `nil` (with optionals) |
| Class | `classdef` | `class Foo:` | `class Foo { }` or `struct Foo { }` |
| String format | `sprintf` | `f"{x}"` | `"\(x)"` (string interpolation) |
| Lambda | `@(x) x^2` | `lambda x: x**2` | `{ x in x * x }` |
| Try/Catch | `try/catch` | `try/except` | `do { try } catch { }` |
| Import | `import pkg` | `import pkg` | `import Framework` |

### Key Xcode Terminology

- **Project (.xcodeproj)**: The container for all your code, like a workspace folder
- **Target**: A single product to build (app, extension, test bundle). Think of it like different entry points
- **Scheme**: Configuration for how to build/run/test a target (like different run configurations)
- **Bundle Identifier**: Unique reverse-DNS name for your app (like `com.stashmystuff.app`)
- **Entitlements**: Permissions your app needs (iCloud, push notifications, etc.)
- **Provisioning Profile**: Apple's way of linking your app to your developer account
- **Simulator**: Virtual iPhone/iPad/Mac for testing (no physical device needed)

### The Xcode Interface

```
┌─────────────────────────────────────────────────────────────────────┐
│  [Navigator]  │  [Editor Area]                    │  [Inspector]    │
│  (left panel) │  (center - where you edit code)   │  (right panel)  │
│               │                                    │                 │
│  - Project    │  ┌─────────────────────────────┐  │  - File info    │
│    navigator  │  │  Tab bar at top:            │  │  - Quick help   │
│  - Source     │  │  General | Signing & Cap... │  │                 │
│    control    │  └─────────────────────────────┘  │                 │
│  - Find       │                                    │                 │
│  - Issues     │                                    │                 │
└─────────────────────────────────────────────────────────────────────┘
                │  [Debug Area / Console] (bottom)                    │
                └─────────────────────────────────────────────────────┘
```

### How to Find Things in Xcode

**To access project/target settings:**
1. Click the **blue project icon** at the very top of the left sidebar (Navigator)
2. This opens the project editor in the center
3. On the LEFT side of the center panel, you'll see:
   - PROJECT section (project-wide settings)
   - TARGETS section (per-target settings like StashMyStuff, StashShareExtension, etc.)
4. Click a target name to configure it
5. The TABS appear at the TOP of the editor area (General, Signing & Capabilities, etc.)

**Keyboard shortcuts:**
- `⌘R` - Run the app
- `⌘B` - Build (compile without running)
- `⌘.` - Stop running app
- `⌘⇧K` - Clean build folder (like clearing cache)
- `⌘1-9` - Switch between navigator tabs

---

## Project-Specific Information

### Bundle Identifiers
- Main App: `com.stashmystuff.app`
- Share Extension: `com.stashmystuff.app.share`
- Widget Extension: `com.stashmystuff.app.widgets`

### App Group
- `group.com.stashmystuff.app` - Shared container for data between app and extensions

### iCloud Container
- `iCloud.com.stashmystuff.app` - CloudKit database identifier

### Target Deployment
- iOS 26.0+ (requires Xcode 16+ beta)
- macOS 26.0+ (requires Xcode 16+ beta)

---

## Code Style

- Swift 6.0
- SwiftUI for all UI
- SwiftData for persistence
- MVVM-C architecture (Model-View-ViewModel with Coordinators)
- No force unwrapping (`!`) - use proper optional handling
- Protocol-oriented design
- Dependency injection via `DependencyContainer`

---

## Liquid Glass Design Guidelines (iOS 26+)

This app uses Apple's Liquid Glass design language. Follow these official guidelines when building UI.

### Core Design Principles

| Principle | Description |
|-----------|-------------|
| **Hierarchy** | Glass floats on the navigation layer; content sits below |
| **Content-First** | UI elements recede when users are reading/creating/watching |
| **Harmony** | Rounded forms follow natural touch patterns |
| **Consistency** | Universal design across iOS, iPadOS, macOS |

### When to Use Glass

| Use Glass For | Don't Use Glass For |
|---------------|---------------------|
| Navigation controls (toolbars, tab bars) | Main content areas |
| Floating action buttons | Background fills |
| Cards that overlay content | Every UI element |
| Interactive controls (buttons, toggles) | Static decorative elements |

### API Quick Reference

```swift
// Basic glass effect
view.glassEffect(.regular, in: .rect(cornerRadius: 16))

// Interactive glass (for buttons, tappable elements)
view.glassEffect(.regular.interactive(), in: .capsule)

// Tinted glass (for category-colored elements)
view.glassEffect(.regular.tint(.orange), in: .rect(cornerRadius: 16))

// Morphing glass shapes (wrap in container)
GlassEffectContainer {
    view.glassEffect(.regular, in: shape)
         .glassEffectID("id", in: namespace)
}
```

### Accessibility Requirements

- **Contrast**: Maintain strong text/icon contrast against glass backgrounds
- **Dynamic Type**: All text must scale with system font size settings
- **Reduce Motion**: Respect user's motion preferences for animations
- **Color Independence**: Don't rely solely on color to convey information

### Our Design System Implementation

| Component | File | Purpose |
|-----------|------|---------|
| `.glassCard()` | `GlassModifier.swift` | Standard glass card with padding |
| `.glassButton()` | `GlassModifier.swift` | Interactive glass for buttons |
| `GlassCard` | `GlassCard.swift` | Reusable container component |
| `CategoryGlassCard` | `GlassCard.swift` | Tinted glass with category color |
| `.rotatingGlow()` | `BadgeModifiers.swift` | Tonal rainbow highlight animation |

### Sources

- [Apple Newsroom: Liquid Glass Introduction](https://www.apple.com/newsroom/2025/06/apple-introduces-a-delightful-and-elegant-new-software-design/)
- [Apple Developer: Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
- [Apple Developer: Applying Liquid Glass to Custom Views](https://developer.apple.com/documentation/SwiftUI/Applying-Liquid-Glass-to-custom-views)

---

## Linting and CI

This project uses SwiftLint and SwiftFormat. **Always run linting before committing.**

### Pre-Commit Checklist

```bash
# Run SwiftFormat to auto-fix formatting
swiftformat StashMyStuff StashMyStuffTests

# Run SwiftLint to check for violations
swiftlint StashMyStuff StashMyStuffTests
```

### Common SwiftLint Rules to Follow

| Rule | Wrong | Correct |
|------|-------|---------|
| `empty_count` | `array.count == 0` | `array.isEmpty` |
| `empty_string` | `string == ""` | `string.isEmpty` |
| `force_try` | `try!` | `do { try } catch {}` or `// swiftlint:disable:next force_try` |
| `trailing_whitespace` | Lines ending with spaces | No trailing whitespace |
| `vertical_whitespace_opening_braces` | Empty line after `{` | No empty line after `{` |
| `vertical_whitespace_closing_braces` | Empty line before `}` | No empty line before `}` |

### Test Code Exceptions

In test files, `try!` is sometimes acceptable for test setup (e.g., creating ModelContainer). Use the inline disable comment:

```swift
// swiftlint:disable:next force_try
return try! ModelContainer(for: schema, configurations: [configuration])
```

### SwiftFormat Rules

SwiftFormat handles most formatting automatically. Key rules:
- Consistent indentation (4 spaces)
- Trailing whitespace removal
- Consistent brace placement
- Import sorting

---

## Common Tasks

### Running the App
1. Select a simulator from the device dropdown (top center of Xcode)
2. Press `⌘R` or click the Play button

### Adding a New Swift File
1. Right-click folder in Navigator → New File
2. Choose "Swift File"
3. Name it and ensure correct target is checked

### Viewing Console Output
- The debug console appears at the bottom when running
- Use `print()` for debugging (but prefer `Logger` for production)

---

## Current Phase: 2 (Design System) - IN PROGRESS

**Completed:**
- Phase 0: Foundation & Project Setup
- Phase 1: Data Layer & Core Models
- Lesson 2.1: Design Tokens
- Lesson 2.2: View Modifiers & Effects

**Current:** Lesson 2.3 - GlassCard Component

See `PROGRESS.md` for detailed lesson tracking and concept mastery.
See `DEVELOPMENT_PLAN.md` for full roadmap.
