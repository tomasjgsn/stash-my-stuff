# Phase 3: Core App Screens & Navigation

> Build all the main views with proper navigation and MVVM architecture.

---

## Overview

This phase implements the complete user interface for Stash My Stuff using everything we built in Phase 2. Unlike Phase 2's interactive lessons, this is a **read-along guide** - the code is already implemented, and you'll learn by reading the explanations and experimenting with previews.

**Format**: Read-along documentation (no exercises)
**Goal**: Understand navigation, MVVM architecture, and how views compose together

---

## What's Included

| Document | Description |
|----------|-------------|
| [Phase3-Complete-Guide.md](./Phase3-Complete-Guide.md) | Comprehensive guide covering all Phase 3 concepts |

---

## File Structure After Completion

```
StashMyStuff/
├── Coordinators/
│   └── AppCoordinator.swift          # Navigation state management
│
├── ViewModels/
│   ├── HomeViewModel.swift           # Home screen state
│   ├── CategoryListViewModel.swift   # Category filtering/sorting
│   ├── ItemDetailViewModel.swift     # Item editing/actions
│   ├── AddEditItemViewModel.swift    # Form validation
│   └── SmartViewListViewModel.swift  # Smart view queries
│
├── Views/
│   ├── Home/
│   │   └── HomeView.swift            # Category grid + smart views
│   │
│   ├── Category/
│   │   ├── CategoryListView.swift    # Filtered item lists
│   │   └── SmartViewListView.swift   # Favorites, uncooked, etc.
│   │
│   ├── Detail/
│   │   └── ItemDetailView.swift      # Full item display
│   │
│   └── Shared/
│       └── AddEditItemSheet.swift    # Add/edit form
│
└── App/
    └── ContentView.swift             # Root navigation
```

---

## Concepts You'll Learn

### Swift Fundamentals
- `@Observable` macro (replaces `ObservableObject`)
- `@MainActor` for UI-thread safety
- `@Environment` for dependency injection
- `NavigationPath` for type-safe navigation

### SwiftUI Patterns
- NavigationStack with typed destinations
- Sheet presentation and dismissal
- List with swipe actions
- Form validation patterns
- Pull-to-refresh
- Search integration

### Architecture Patterns
- MVVM (Model-View-ViewModel)
- Coordinator pattern for navigation
- Repository pattern (from Phase 1)
- Dependency injection via Environment

---

## How to Use This Guide

1. **Read** the complete guide to understand the architecture
2. **Open Xcode** and look at the implemented files
3. **Run previews** to see components in action
4. **Experiment** - modify preview data to see different states
5. **Reference** this guide when building similar patterns

---

## Quick Reference

### Navigation
```swift
// Navigate to a category
coordinator.navigateToCategory(.recipe)

// Navigate to an item
coordinator.navigateToItem(item)

// Show add sheet
coordinator.showAddItem()
coordinator.showAddItem(for: .recipe)  // Pre-selected category

// Show edit sheet
coordinator.showEditItem(item)
```

### ViewModels
```swift
// Create ViewModel in view's onAppear
@State private var viewModel: HomeViewModel?

.onAppear {
    if viewModel == nil {
        let repository = StashRepository(modelContext: modelContext)
        viewModel = HomeViewModel(repository: repository)
    }
}
```

### Environment
```swift
@Environment(\.modelContext) private var modelContext
@Environment(AppCoordinator.self) private var coordinator
```

---

## Next Phase

After completing Phase 3, you'll move to **Phase 4: Polish & Extensions** where you'll:
- Add the Share Extension
- Create Home Screen Widgets
- Implement CloudKit sync
- Add app settings and preferences

---

*This code is complete and building. Explore the previews!*
