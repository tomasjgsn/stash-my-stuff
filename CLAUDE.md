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

## Xcode Concepts for Python/MATLAB Developers

### Project Structure (vs Python)

| Python Concept | Xcode/Swift Equivalent |
|----------------|------------------------|
| `requirements.txt` / `pyproject.toml` | Swift Package Manager (SPM) or CocoaPods |
| Virtual environment | Not needed - Swift compiles to binary |
| `__init__.py` modules | Swift modules are implicit per target |
| `if __name__ == "__main__"` | `@main` attribute on App struct |
| `pip install` | Add package in Xcode or edit `Package.swift` |

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

## Current Phase: 0 (Foundation) - COMPLETED

See DEVELOPMENT_PLAN.md for full roadmap.
