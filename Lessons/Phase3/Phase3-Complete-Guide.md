# Phase 3: Complete Guide to Core App Screens

> A comprehensive read-along guide to understanding the navigation architecture and MVVM pattern in Stash My Stuff.

---

## Table of Contents

1. [Introduction](#introduction)
2. [Architecture Overview](#architecture-overview)
3. [The Coordinator Pattern](#the-coordinator-pattern)
4. [Understanding @Observable](#understanding-observable)
5. [NavigationStack Deep Dive](#navigationstack-deep-dive)
6. [HomeView - The Category Grid](#homeview---the-category-grid)
7. [CategoryListView - Filtering and Lists](#categorylistview---filtering-and-lists)
8. [SmartViewListView - Pre-Filtered Queries](#smartviewlistview---pre-filtered-queries)
9. [ItemDetailView - The Full Picture](#itemdetailview---the-full-picture)
10. [AddEditItemSheet - Form Handling](#addedititemsheet---form-handling)
11. [ContentView - Wiring It Together](#contentview---wiring-it-together)
12. [Preview Patterns](#preview-patterns)
13. [Quick Reference](#quick-reference)

---

## Introduction

Phase 3 brings everything together. You've built:
- **Phase 1**: Data layer with SwiftData models and repository
- **Phase 2**: Design system with glass effects, components, and animations

Now we build the **screens** that users actually see and interact with. This phase teaches you:
- How to structure SwiftUI apps with proper separation of concerns
- The MVVM pattern for managing state
- Type-safe navigation with NavigationStack
- Sheet presentation for modals
- Form validation patterns

**Key Insight**: Views should be "dumb" - they display data and forward user actions. ViewModels handle the logic. Coordinators handle navigation. This separation makes code testable and maintainable.

---

## Architecture Overview

### The Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        ContentView                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   NavigationStack                          │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │                     HomeView                         │  │  │
│  │  │  ┌─────────────┐    ┌─────────────────────────────┐ │  │  │
│  │  │  │ Smart Views │    │     Category Grid           │ │  │  │
│  │  │  │  (scroll)   │    │  ┌───┐ ┌───┐ ┌───┐ ┌───┐   │ │  │  │
│  │  │  │             │    │  │   │ │   │ │   │ │   │   │ │  │  │
│  │  │  └─────────────┘    │  └───┘ └───┘ └───┘ └───┘   │ │  │  │
│  │  │                     └─────────────────────────────┘ │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │                              │                             │  │
│  │                              ▼                             │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │               CategoryListView                       │  │  │
│  │  │  ┌─────────────────────────────────────────────┐    │  │  │
│  │  │  │  Filter Tabs: All | To Do | Done | Favorites │    │  │  │
│  │  │  └─────────────────────────────────────────────┘    │  │  │
│  │  │  ┌─────────────────────────────────────────────┐    │  │  │
│  │  │  │                Item List                     │    │  │  │
│  │  │  │  ├── StashItemRow (swipe actions)           │    │  │  │
│  │  │  │  ├── StashItemRow                           │    │  │  │
│  │  │  │  └── StashItemRow                           │    │  │  │
│  │  │  └─────────────────────────────────────────────┘    │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  │                              │                             │  │
│  │                              ▼                             │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │                 ItemDetailView                       │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  AddEditItemSheet (modal)                  │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### File Relationships

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  AppCoordinator │────▶│    ViewModel    │────▶│  StashRepository │
│  (navigation)   │     │  (business logic)│     │  (data access)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        │                       │                       │
        ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  NavigationPath │     │   @Observable   │     │   SwiftData     │
│  (state)        │     │   (reactive)    │     │   ModelContext  │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

---

## The Coordinator Pattern

### What is a Coordinator?

A Coordinator is an object that handles **navigation flow**. Instead of views knowing how to navigate to other views, they ask the coordinator. This:
- Decouples views from each other
- Makes navigation testable
- Centralizes navigation logic
- Enables deep linking

### Python/MATLAB Analogy

Think of it like a central controller that manages which "figure" or "window" is shown:

```python
# Python pseudocode - what a coordinator does conceptually
class AppCoordinator:
    def __init__(self):
        self.navigation_stack = []
        self.current_modal = None

    def show_category(self, category):
        self.navigation_stack.append(CategoryScreen(category))

    def show_add_item(self):
        self.current_modal = AddItemSheet()
```

### The AppCoordinator in Swift

**File**: `StashMyStuff/Coordinators/AppCoordinator.swift`

```swift
import SwiftUI

// MARK: - Navigation Destinations
// This enum defines all possible navigation destinations in the app.
// Using an enum with associated values gives us type-safe navigation.
enum AppDestination: Hashable {
    case category(Category)           // Navigate to a category's item list
    case itemDetail(StashItem)        // Navigate to item detail view
    case smartView(SmartView)         // Navigate to a smart view (Favorites, etc.)
    case settings                     // Navigate to settings
    case search                       // Navigate to search
}

// MARK: - Smart View Types
// Pre-defined filtered views that show specific subsets of items.
// Each smart view maps to a repository query method.
enum SmartView: String, Hashable, CaseIterable, Identifiable {
    case uncookedRecipes = "Uncooked Recipes"
    case toRead = "To Read"
    case bandcampQueue = "Bandcamp Queue"
    case unwatched = "Unwatched"
    case favorites = "Favorites"
    case recentlyAdded = "Recently Added"

    var id: String { rawValue }

    // Each smart view gets a distinctive icon
    var icon: String {
        switch self {
        case .uncookedRecipes: return "frying.pan"
        case .toRead: return "book.closed"
        case .bandcampQueue: return "headphones"
        case .unwatched: return "film"
        case .favorites: return "heart.fill"
        case .recentlyAdded: return "clock"
        }
    }

    // Each smart view gets a color from the related category
    var color: Color {
        switch self {
        case .uncookedRecipes: return Category.recipe.color
        case .toRead: return Category.book.color
        case .bandcampQueue: return Category.music.color
        case .unwatched: return Category.movie.color
        case .favorites: return .red
        case .recentlyAdded: return .blue
        }
    }
}

// MARK: - App Coordinator
// The central navigation controller for the entire app.
// Using @Observable makes all navigation state automatically reactive.
@Observable
@MainActor
final class AppCoordinator {
    // MARK: - Navigation State

    // NavigationPath is SwiftUI's type-erased container for navigation state.
    // It can hold any Hashable values and drives NavigationStack.
    var navigationPath = NavigationPath()

    // MARK: - Sheet State

    // These properties control modal presentation
    var showingAddSheet = false
    var editingItem: StashItem?        // Non-nil when editing existing item
    var selectedCategory: Category?     // Pre-selected category for new items

    // MARK: - Navigation Methods

    // Generic navigation - push any destination onto the stack
    func navigate(to destination: AppDestination) {
        navigationPath.append(destination)
    }

    // Convenience methods make call sites cleaner
    func navigateToCategory(_ category: Category) {
        navigate(to: .category(category))
    }

    func navigateToItem(_ item: StashItem) {
        navigate(to: .itemDetail(item))
    }

    func navigateToSmartView(_ smartView: SmartView) {
        navigate(to: .smartView(smartView))
    }

    func showSettings() {
        navigate(to: .settings)
    }

    func showSearch() {
        navigate(to: .search)
    }

    // MARK: - Sheet Methods

    // Show add sheet with optional pre-selected category
    func showAddItem(for category: Category? = nil) {
        selectedCategory = category
        editingItem = nil
        showingAddSheet = true
    }

    // Show edit sheet for existing item
    func showEditItem(_ item: StashItem) {
        selectedCategory = item.category
        editingItem = item
        showingAddSheet = true
    }

    // Dismiss any open sheet
    func dismissSheet() {
        showingAddSheet = false
        editingItem = nil
        selectedCategory = nil
    }

    // Pop back one screen in the navigation stack
    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
}
```

### Key Concepts Explained

#### 1. `@Observable` macro

This is Swift 5.9's replacement for `ObservableObject`. It automatically makes all stored properties reactive - when they change, SwiftUI views update.

```swift
// Old way (still works, but verbose)
class OldCoordinator: ObservableObject {
    @Published var showingSheet = false
}

// New way with @Observable (Swift 5.9+)
@Observable
class NewCoordinator {
    var showingSheet = false  // Automatically published!
}
```

#### 2. `@MainActor`

This ensures all code runs on the main thread. UI code **must** run on the main thread, and Swift 6 enforces this strictly.

```swift
@MainActor
final class AppCoordinator {
    // All methods are guaranteed to run on main thread
    func navigate(to destination: AppDestination) {
        // Safe to update UI state here
        navigationPath.append(destination)
    }
}
```

#### 3. `NavigationPath`

A type-erased container that can hold any `Hashable` values. It's what drives `NavigationStack`.

```swift
// You can push different types onto the same path
navigationPath.append(AppDestination.category(.recipe))
navigationPath.append(AppDestination.itemDetail(someItem))

// Pop the last item
navigationPath.removeLast()

// Check if empty
if navigationPath.isEmpty { /* at root */ }
```

---

## Understanding @Observable

### The Evolution of State Management

SwiftUI's state management has evolved:

| Era | Pattern | Boilerplate |
|-----|---------|-------------|
| SwiftUI 1.0 | `ObservableObject` + `@Published` | High |
| SwiftUI 4.0 | `@StateObject` wrapper | Medium |
| SwiftUI 5.0 (iOS 17+) | `@Observable` macro | Low |

### How @Observable Works

The `@Observable` macro expands your class with automatic change tracking:

```swift
// What you write:
@Observable
class ViewModel {
    var count = 0
    var name = ""
}

// What Swift generates (simplified):
class ViewModel: Observable {
    private var _count = 0
    private var _name = ""

    var count: Int {
        get {
            access(keyPath: \.count)
            return _count
        }
        set {
            withMutation(keyPath: \.count) {
                _count = newValue
            }
        }
    }
    // ... similar for name
}
```

### Using @Observable in Views

```swift
struct MyView: View {
    // For coordinator passed via environment
    @Environment(AppCoordinator.self) private var coordinator

    // For view-owned state
    @State private var viewModel: MyViewModel?

    var body: some View {
        // Views automatically update when @Observable properties change
        Text("\(coordinator.navigationPath.count) screens deep")
    }
}
```

---

## NavigationStack Deep Dive

### The Old Way vs The New Way

```swift
// Old: NavigationView with NavigationLink
NavigationView {
    NavigationLink(destination: DetailView(item: item)) {
        Text("Go to detail")
    }
}

// New: NavigationStack with typed destinations
NavigationStack(path: $coordinator.navigationPath) {
    RootView()
        .navigationDestination(for: AppDestination.self) { destination in
            switch destination {
            case .category(let category):
                CategoryListView(category: category)
            case .itemDetail(let item):
                ItemDetailView(item: item)
            // ... etc
            }
        }
}
```

### Why NavigationStack is Better

1. **Programmatic Navigation**: Push/pop from anywhere via the coordinator
2. **Type Safety**: Destinations are strongly typed via enum
3. **Deep Linking**: Just populate the path array
4. **State Preservation**: Navigation state is just data

### Navigation Flow Example

```swift
// User taps a category card in HomeView
Button {
    coordinator.navigateToCategory(.recipe)  // Pushes onto path
} label: {
    CategoryCard(.recipe, itemCount: 5, style: .grid)
}

// In ContentView, NavigationStack reacts:
NavigationStack(path: $coordinator.navigationPath) {
    HomeView()
        .navigationDestination(for: AppDestination.self) { destination in
            // This closure is called for .category(.recipe)
            destinationView(for: destination)
        }
}

// destinationView returns the right view:
@ViewBuilder
func destinationView(for destination: AppDestination) -> some View {
    switch destination {
    case .category(let category):
        CategoryListView(category: category)  // This appears!
    // ...
    }
}
```

---

## HomeView - The Category Grid

**File**: `StashMyStuff/Views/Home/HomeView.swift`

HomeView is the app's main screen - what users see when they open the app.

### Structure Overview

```
┌─────────────────────────────────────────────────────────────┐
│  Navigation Title: "Stash"                         [+] Add  │
├─────────────────────────────────────────────────────────────┤
│  🔍 Search items...                                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Smart Views (horizontal scroll)                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                    │
│  │ Uncooked │ │ To Read  │ │Favorites │ ...               │
│  │ Recipes  │ │          │ │          │                    │
│  │    3     │ │    7     │ │    12    │                    │
│  └──────────┘ └──────────┘ └──────────┘                    │
│                                                             │
│  Categories                                                 │
│  ┌───────────────┐ ┌───────────────┐                       │
│  │   Recipes     │ │    Books      │                       │
│  │      🍳       │ │      📚       │                       │
│  │      15       │ │       8       │                       │
│  └───────────────┘ └───────────────┘                       │
│  ┌───────────────┐ ┌───────────────┐                       │
│  │   Movies      │ │    Music      │                       │
│  │      🎬       │ │      🎵       │                       │
│  │      23       │ │      45       │                       │
│  └───────────────┘ └───────────────┘                       │
│  ... (continues for all 10 categories)                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### The HomeViewModel

The ViewModel handles all data operations:

```swift
@Observable
@MainActor
final class HomeViewModel {
    // MARK: - Dependencies
    private let repository: StashRepository

    // MARK: - State
    var searchText = ""
    var isSearching = false
    var searchResults: [StashItem] = []
    private(set) var categoryCounts: [Category: Int] = [:]
    private(set) var smartViewCounts: [SmartView: Int] = [:]

    // MARK: - Initialization
    init(repository: StashRepository) {
        self.repository = repository
        loadData()
    }

    // MARK: - Data Loading
    func loadData() {
        // Load counts for each category
        for category in Category.allCases {
            categoryCounts[category] = repository.fetchByCategory(category).count
        }

        // Load counts for each smart view
        loadSmartViewCounts()
    }

    // MARK: - Computed Properties

    // Only show smart views that have items
    var activeSmartViews: [SmartView] {
        SmartView.allCases.filter { smartViewCounts[$0, default: 0] > 0 }
    }

    // Total items across all categories
    var totalItemCount: Int {
        categoryCounts.values.reduce(0, +)
    }
}
```

### Key View Code Explained

#### Grid Layout

```swift
// Define a 2-column grid with flexible sizing
private let categoryColumns = [
    GridItem(.flexible(), spacing: DesignTokens.Spacing.md),
    GridItem(.flexible(), spacing: DesignTokens.Spacing.md)
]

// Use LazyVGrid for efficient rendering
LazyVGrid(columns: categoryColumns, spacing: DesignTokens.Spacing.md) {
    ForEach(Category.allCases, id: \.self) { category in
        Button {
            coordinator.navigateToCategory(category)
        } label: {
            CategoryCard(
                category,
                itemCount: viewModel?.count(for: category) ?? 0,
                style: .grid
            )
        }
        .buttonStyle(.plain)  // Removes default button styling
    }
}
```

**Why `.buttonStyle(.plain)`?**

By default, buttons have a tint color and dimming effect. `.plain` lets us use completely custom styling in `CategoryCard`.

#### Smart Views Horizontal Scroll

```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: DesignTokens.Spacing.sm) {
        ForEach(viewModel.activeSmartViews) { smartView in
            SmartViewCard(
                smartView: smartView,
                count: viewModel.count(for: smartView)
            ) {
                coordinator.navigateToSmartView(smartView)
            }
        }
    }
}
```

**Note**: `showsIndicators: false` hides the scroll bars for a cleaner look.

#### Search Overlay Pattern

```swift
var body: some View {
    ScrollView { /* main content */ }
        .searchable(text: $searchText, prompt: "Search items...")
        .onChange(of: searchText) { _, newValue in
            viewModel?.searchText = newValue
            viewModel?.performSearch()
        }
        .overlay {
            // Show search results when actively searching
            if let vm = viewModel, vm.isSearching {
                searchResultsOverlay(viewModel: vm)
            }
        }
}

@ViewBuilder
func searchResultsOverlay(viewModel: HomeViewModel) -> some View {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()  // Cover main content

        if viewModel.searchResults.isEmpty {
            ContentUnavailableView.search(text: searchText)
        } else {
            List(viewModel.searchResults) { item in
                // ... search result rows
            }
        }
    }
}
```

**Why overlay instead of replacing content?**

Using `.overlay` keeps the main content in the view hierarchy (for smooth transitions) while visually covering it during search.

---

## CategoryListView - Filtering and Lists

**File**: `StashMyStuff/Views/Category/CategoryListView.swift`

This view shows all items in a single category with filtering, sorting, and swipe actions.

### Structure Overview

```
┌─────────────────────────────────────────────────────────────┐
│  ← Back    Recipes                              [+] [Sort]  │
├─────────────────────────────────────────────────────────────┤
│  🔍 Search recipes...                                       │
├─────────────────────────────────────────────────────────────┤
│  ┌────┐ ┌────────┐ ┌──────┐ ┌──────────┐                   │
│  │All │ │ To Do  │ │ Done │ │ Favorites│                   │
│  └────┘ └────────┘ └──────┘ └──────────┘                   │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 🍳 Chocolate Chip Cookies           ⭐                  ││
│  │    cooking.nytimes.com                                  ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐│
│  │ 🍳 Homemade Pizza                                       ││
│  │    allrecipes.com                                       ││
│  └─────────────────────────────────────────────────────────┘│
│  ... (continues)                                            │
└─────────────────────────────────────────────────────────────┘
```

### The CategoryListViewModel

```swift
@Observable
@MainActor
final class CategoryListViewModel {
    // MARK: - Dependencies
    private let repository: StashRepository
    let category: Category

    // MARK: - State
    var filter: ItemFilter = .all
    var sortOption: SortOption = .dateAdded
    var searchText = ""
    private(set) var items: [StashItem] = []

    // MARK: - Computed Properties

    var filteredItems: [StashItem] {
        var result = items

        // Apply filter
        switch filter {
        case .all:
            break  // No filtering
        case .incomplete:
            result = result.filter { item in
                // Item is incomplete if primary flag is false or missing
                if let flagKey = primaryFlagKey {
                    return !(item.flags[flagKey] ?? false)
                }
                return true
            }
        case .complete:
            result = result.filter { item in
                if let flagKey = primaryFlagKey {
                    return item.flags[flagKey] ?? false
                }
                return false
            }
        case .favorites:
            result = result.filter(\.isFavorite)
        }

        // Apply search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query)
            }
        }

        return result
    }

    // The primary flag for this category (e.g., "hasBeenCooked" for recipes)
    var primaryFlagKey: String? {
        category.config.availableFlags.first(where: { $0.isPrimary })?.key
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    var emptyMessage: String {
        if !searchText.isEmpty {
            return "No \(category.rawValue.lowercased()) match your search"
        }
        return "No \(category.rawValue.lowercased()) yet"
    }
}
```

### Filter Tabs Implementation

```swift
enum ItemFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case incomplete = "To Do"
    case complete = "Done"
    case favorites = "Favorites"

    var id: String { rawValue }
}

// Custom filter tab button
struct FilterTabButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignTokens.Typography.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background {
                    Capsule()
                        .fill(isSelected ? color : Color(.systemGray5))
                }
        }
        .buttonStyle(.plain)
    }
}
```

### Swipe Actions Deep Dive

SwiftUI's `.swipeActions` modifier adds iOS-style swipe gestures to list rows:

```swift
List {
    ForEach(viewModel.filteredItems) { item in
        StashItemRow(item: item, style: .standard)
            // Trailing swipe (right-to-left) - destructive action
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    viewModel.deleteItem(item)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            // Leading swipe (left-to-right) - non-destructive actions
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                Button {
                    viewModel.toggleFavorite(item)
                } label: {
                    Label(
                        item.isFavorite ? "Unfavorite" : "Favorite",
                        systemImage: item.isFavorite ? "heart.slash" : "heart"
                    )
                }
                .tint(item.isFavorite ? .gray : .red)

                // Show quick-complete button for primary flag
                if let flagKey = viewModel.primaryFlagKey {
                    Button {
                        viewModel.toggleFlag(flagKey, for: item)
                    } label: {
                        let isActive = item.flags[flagKey] ?? false
                        Label(
                            isActive ? "Undo" : "Done",
                            systemImage: isActive ? "arrow.uturn.backward" : "checkmark"
                        )
                    }
                    .tint(.green)
                }
            }
    }
}
```

**Key Points:**
- `allowsFullSwipe: true` means a full swipe triggers the first action automatically
- `role: .destructive` gives the button red styling
- `.tint()` sets the button's background color
- Multiple buttons appear as a stack when partially swiped

---

## SmartViewListView - Pre-Filtered Queries

**File**: `StashMyStuff/Views/Category/SmartViewListView.swift`

Smart views are pre-defined filters that show specific item subsets, like "Uncooked Recipes" or "Favorites".

### The SmartViewListViewModel

```swift
@Observable
@MainActor
final class SmartViewListViewModel {
    private let repository: StashRepository
    let smartView: SmartView

    var sortOption: SortOption = .dateAdded
    private(set) var items: [StashItem] = []

    init(smartView: SmartView, repository: StashRepository) {
        self.smartView = smartView
        self.repository = repository
        loadItems()
    }

    func loadItems() {
        // Each smart view maps to a specific repository method
        switch smartView {
        case .uncookedRecipes:
            items = repository.uncookedRecipes()
        case .toRead:
            items = repository.toRead()
        case .bandcampQueue:
            items = repository.bandcampQueue()
        case .unwatched:
            items = repository.unwatchedMovies()
        case .favorites:
            items = repository.favorites()
        case .recentlyAdded:
            items = repository.recent(limit: 20)
        }

        applySorting()
    }

    // Dynamic UI properties based on smart view type
    var title: String { smartView.rawValue }
    var icon: String { smartView.icon }

    var emptyMessage: String {
        switch smartView {
        case .uncookedRecipes:
            return "All recipes have been cooked!"
        case .toRead:
            return "Nothing left to read"
        case .bandcampQueue:
            return "No music waiting to be bought"
        case .unwatched:
            return "You've watched everything!"
        case .favorites:
            return "No favorites yet. Swipe right on items to add them."
        case .recentlyAdded:
            return "No items yet"
        }
    }
}
```

### Simplified View (No Filters)

Unlike CategoryListView, SmartViewListView doesn't need filter tabs - the smart view IS the filter:

```swift
struct SmartViewListView: View {
    let smartView: SmartView
    @State private var viewModel: SmartViewListViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                if vm.isEmpty {
                    emptyStateView(viewModel: vm)
                } else {
                    listContent(viewModel: vm)
                }
            } else {
                ProgressView()  // Loading state
            }
        }
        .navigationTitle(smartView.rawValue)
        .onAppear {
            if viewModel == nil {
                let repository = StashRepository(modelContext: modelContext)
                viewModel = SmartViewListViewModel(smartView: smartView, repository: repository)
            }
        }
    }
}
```

---

## ItemDetailView - The Full Picture

**File**: `StashMyStuff/Views/Detail/ItemDetailView.swift`

This view displays all information about a single stash item with sections for metadata, flags, notes, and tags.

### Structure Overview

```
┌─────────────────────────────────────────────────────────────┐
│  ← Back    Item Title                             [Edit]    │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────────┐│
│  │                   Hero Image                    [♡]     ││
│  │                  (or placeholder)                       ││
│  └─────────────────────────────────────────────────────────┘│
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────┐ │
│  │ 🍳 Recipe          Added Dec 15, 2024                  │ │
│  │ Chocolate Chip Cookies                                 │ │
│  │ cooking.nytimes.com/recipe/123                        │ │
│  └────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Cooked: ☐    Favorite: ☑                              │ │
│  │ Rating: ★★★★☆                                         │ │
│  └────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Notes                                                  │ │
│  │ "This recipe needs more chocolate chips..."            │ │
│  └────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Tags                                                   │ │
│  │ [dessert] [chocolate] [baking]                        │ │
│  └────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐  ┌─────────────────────────────┐  │
│  │    🔗 Open Link     │  │      🗑️ Delete Item        │  │
│  └─────────────────────┘  └─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### The ItemDetailViewModel

```swift
@Observable
@MainActor
final class ItemDetailViewModel {
    private let repository: StashRepository
    let item: StashItem

    // UI State
    var showingDeleteConfirmation = false
    var isDeleted = false

    init(item: StashItem, repository: StashRepository) {
        self.item = item
        self.repository = repository
    }

    // MARK: - Actions

    func toggleFavorite() {
        item.isFavorite.toggle()
        save()
        HapticService.shared.flagToggled(isNowActive: item.isFavorite)
    }

    func toggleFlag(_ flagKey: String) {
        let currentValue = item.flags[flagKey] ?? false
        item.flags[flagKey] = !currentValue
        save()
        HapticService.shared.flagToggled(isNowActive: !currentValue)
    }

    func updateRating(_ rating: Int) {
        // Find the rating flag and update it
        if let ratingFlag = item.category.config.availableFlags.first(where: { $0.isRating }) {
            item.flags[ratingFlag.key] = true  // Mark as rated
            // Store actual rating in metadata
            item.metadata["rating"] = String(rating)
        }
        save()
    }

    func openLink() {
        guard let url = item.sourceURL else { return }

        #if canImport(UIKit)
        UIApplication.shared.open(url)
        #elseif canImport(AppKit)
        NSWorkspace.shared.open(url)
        #endif
    }

    func deleteItem() {
        repository.delete(item)
        isDeleted = true
    }

    private func save() {
        repository.save(item)
    }
}
```

### Hero Section with Favorite Overlay

```swift
@ViewBuilder
private func heroSection(viewModel: ItemDetailViewModel) -> some View {
    ZStack(alignment: .topTrailing) {
        // Thumbnail image (or placeholder)
        ItemThumbnail(
            url: viewModel.item.sourceURL,
            category: viewModel.item.category,
            style: .hero
        )
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .clipped()

        // Favorite button overlaid in top-right
        Button {
            viewModel.toggleFavorite()
        } label: {
            Image(systemName: viewModel.item.isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(viewModel.item.isFavorite ? .red : .primary)
                .padding(DesignTokens.Spacing.sm)
                .background {
                    Circle()
                        .fill(.ultraThinMaterial)
                }
        }
        .padding(DesignTokens.Spacing.md)
    }
}
```

### Platform-Specific Code

When code needs to work on both iOS and macOS, use conditional compilation:

```swift
func openLink() {
    guard let url = item.sourceURL else { return }

    #if canImport(UIKit)
    // iOS/iPadOS/tvOS
    UIApplication.shared.open(url)
    #elseif canImport(AppKit)
    // macOS
    NSWorkspace.shared.open(url)
    #endif
}
```

### Delete Confirmation Dialog

```swift
var body: some View {
    ScrollView { /* content */ }
        .confirmationDialog(
            "Delete Item",
            isPresented: $viewModel.showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteItem()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete \"\(viewModel.item.title)\"? This cannot be undone.")
        }
        .onChange(of: viewModel.isDeleted) { _, isDeleted in
            if isDeleted {
                coordinator.goBack()  // Pop back after deletion
            }
        }
}
```

---

## AddEditItemSheet - Form Handling

**File**: `StashMyStuff/Views/Shared/AddEditItemSheet.swift`

This sheet handles both creating new items and editing existing ones.

### The AddEditItemViewModel

```swift
@Observable
@MainActor
final class AddEditItemViewModel {
    // MARK: - Mode
    let isEditing: Bool
    private let existingItem: StashItem?
    private var repository: StashRepository?

    // MARK: - Form Fields
    var title: String = ""
    var category: Category = .recipe
    var sourceURL: String = ""
    var notes: String = ""
    var tags: [String] = []
    var isFavorite: Bool = false
    var flags: [String: Bool] = [:]

    // MARK: - Validation State
    var titleError: String?
    var urlError: String?

    // MARK: - Initialization

    // For new items
    init(category: Category? = nil) {
        self.isEditing = false
        self.existingItem = nil
        self.category = category ?? .recipe
        initializeFlags()
    }

    // For editing existing items
    init(item: StashItem) {
        self.isEditing = true
        self.existingItem = item
        self.title = item.title
        self.category = item.category
        self.sourceURL = item.sourceURL?.absoluteString ?? ""
        self.notes = item.notes ?? ""
        self.tags = item.tags.map(\.name)
        self.isFavorite = item.isFavorite
        self.flags = item.flags
    }

    // MARK: - Validation

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // Parse URL with automatic https:// prefix
    var parsedURL: URL? {
        guard !sourceURL.isEmpty else { return nil }

        var urlString = sourceURL.trimmingCharacters(in: .whitespacesAndNewlines)

        // Add https:// if no scheme present
        if !urlString.contains("://") {
            urlString = "https://\(urlString)"
        }

        return URL(string: urlString)
    }

    // MARK: - Save

    func save() {
        guard isValid else { return }

        if isEditing, let item = existingItem {
            // Update existing item
            item.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            item.category = category
            item.sourceURL = parsedURL
            item.notes = notes.isEmpty ? nil : notes
            item.isFavorite = isFavorite
            item.flags = flags
            // Note: Tag updating would require Tag CRUD in repository
            repository?.save(item)
        } else {
            // Create new item
            let newItem = StashItem(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                category: category,
                sourceURL: parsedURL
            )
            newItem.notes = notes.isEmpty ? nil : notes
            newItem.isFavorite = isFavorite
            newItem.flags = flags
            repository?.save(newItem)
        }
    }
}
```

### Form Structure

```swift
var body: some View {
    NavigationStack {
        Form {
            // Category picker (horizontal scroll)
            categorySection

            // Title and URL
            Section("Details") {
                TextField("Title", text: $viewModel.title)
                    .textInputAutocapitalization(.words)

                HStack {
                    TextField("URL (optional)", text: $viewModel.sourceURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)

                    // URL validation indicator
                    if !viewModel.sourceURL.isEmpty {
                        Image(systemName: viewModel.parsedURL != nil ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(viewModel.parsedURL != nil ? .green : .red)
                    }
                }
            }

            // Tags
            Section("Tags") {
                TagInput(tags: $viewModel.tags, suggestions: [])
            }

            // Category-specific flags
            flagsSection

            // Notes
            Section("Notes") {
                TextEditor(text: $viewModel.notes)
                    .frame(minHeight: 100)
            }

            // Options
            Section {
                Toggle("Favorite", isOn: $viewModel.isFavorite)
            }
        }
        .navigationTitle(viewModel.isEditing ? "Edit Item" : "Add Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    coordinator.dismissSheet()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(viewModel.isEditing ? "Save" : "Add") {
                    viewModel.save()
                    coordinator.dismissSheet()
                }
                .disabled(!viewModel.isValid)
            }
        }
    }
}
```

### Category Picker with Visual Selection

```swift
@ViewBuilder
private var categorySection: some View {
    Section {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(Category.allCases, id: \.self) { category in
                    CategoryPickerItem(
                        category: category,
                        isSelected: viewModel.category == category
                    ) {
                        withAnimation(.bouncy) {
                            viewModel.category = category
                            viewModel.initializeFlags()  // Reset flags for new category
                        }
                        HapticService.shared.selectionChanged()
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
        }
        .listRowInsets(EdgeInsets())  // Remove default padding
    } header: {
        Text("Category")
    }
}

struct CategoryPickerItem: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignTokens.Spacing.xs) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? category.color : .secondary)

                Text(category.rawValue)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
            .frame(width: 70, height: 70)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                        .fill(category.color.opacity(0.15))
                }
            }
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                        .stroke(category.color, lineWidth: 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
```

### Dynamic Flags Based on Category

```swift
@ViewBuilder
private var flagsSection: some View {
    let availableFlags = viewModel.category.config.availableFlags

    if !availableFlags.isEmpty {
        Section("Status") {
            ForEach(availableFlags, id: \.key) { flagDef in
                // Skip rating flags - they need special UI
                if !flagDef.isRating {
                    Toggle(isOn: Binding(
                        get: { viewModel.flags[flagDef.key] ?? false },
                        set: { viewModel.flags[flagDef.key] = $0 }
                    )) {
                        Label(flagDef.name, systemImage: flagDef.icon)
                    }
                }
            }
        }
    }
}
```

---

## ContentView - Wiring It Together

**File**: `StashMyStuff/App/ContentView.swift`

ContentView is the root of the app. It sets up navigation and the coordinator.

### The Complete Implementation

```swift
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var coordinator = AppCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            HomeView()
                .navigationDestination(for: AppDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
        .environment(coordinator)  // Inject into all child views
        .sheet(isPresented: $coordinator.showingAddSheet) {
            AddEditItemSheet(
                existingItem: coordinator.editingItem,
                initialCategory: coordinator.selectedCategory
            )
            .environment(coordinator)  // Sheets need their own injection
        }
    }

    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case .category(let category):
            CategoryListView(category: category)

        case .itemDetail(let item):
            ItemDetailView(item: item)

        case .smartView(let smartView):
            SmartViewListView(smartView: smartView)

        case .settings:
            SettingsView()

        case .search:
            SearchView()
        }
    }
}
```

### Key Concepts

#### Environment Injection

The coordinator is passed to all child views via `.environment()`:

```swift
.environment(coordinator)
```

Child views access it with:

```swift
@Environment(AppCoordinator.self) private var coordinator
```

**Important**: Sheets create a new presentation context and don't inherit environment by default. That's why we also add `.environment(coordinator)` to the sheet.

#### NavigationStack Binding

The `path:` parameter binds the navigation stack to our coordinator's path:

```swift
NavigationStack(path: $coordinator.navigationPath) {
```

When we call `coordinator.navigateToCategory(.recipe)`, it appends to `navigationPath`, and NavigationStack automatically pushes the view returned by `navigationDestination`.

---

## Preview Patterns

### Basic Preview

```swift
#Preview("HomeView") {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: [StashItem.self, Tag.self], inMemory: true)
    .environment(AppCoordinator())
}
```

### Preview with Sample Data

```swift
#Preview("HomeView with Data") {
    // Create in-memory container
    let container = try! ModelContainer(
        for: StashItem.self, Tag.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // Get context for inserting data
    let context = container.mainContext

    // Create sample items
    let items = [
        StashItem(title: "Chocolate Chip Cookies", category: .recipe, sourceURL: URL(string: "https://cooking.nytimes.com")),
        StashItem(title: "The Great Gatsby", category: .book, sourceURL: nil)
    ]

    // Insert into context
    for item in items {
        context.insert(item)
    }

    // Set some properties
    items[0].isFavorite = true
    items[0].flags["hasBeenCooked"] = true

    return NavigationStack {
        HomeView()
    }
    .modelContainer(container)
    .environment(AppCoordinator())
}
```

### Preview Empty State

```swift
#Preview("CategoryListView - Empty") {
    NavigationStack {
        CategoryListView(category: .recipe)
    }
    .modelContainer(for: [StashItem.self, Tag.self], inMemory: true)
    .environment(AppCoordinator())
}
```

### Why Previews Matter

1. **Rapid iteration**: See changes without running the full app
2. **State testing**: Easily test empty, loading, and error states
3. **Multiple configurations**: See different data at once
4. **Isolation**: Preview one component without its dependencies

---

## Quick Reference

### Creating a New View with ViewModel

```swift
// 1. Define the ViewModel
@Observable
@MainActor
final class MyViewModel {
    private let repository: StashRepository
    var data: [MyModel] = []

    init(repository: StashRepository) {
        self.repository = repository
        loadData()
    }

    func loadData() {
        data = repository.fetchAll()
    }
}

// 2. Create the View
struct MyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: MyViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                // Main content
                List(vm.data) { item in
                    Text(item.title)
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if viewModel == nil {
                let repository = StashRepository(modelContext: modelContext)
                viewModel = MyViewModel(repository: repository)
            }
        }
    }
}
```

### Navigation Actions

```swift
// Push to navigation stack
coordinator.navigateToCategory(.recipe)
coordinator.navigateToItem(item)
coordinator.navigateToSmartView(.favorites)

// Pop from stack
coordinator.goBack()

// Present sheet
coordinator.showAddItem()
coordinator.showAddItem(for: .recipe)
coordinator.showEditItem(item)

// Dismiss sheet
coordinator.dismissSheet()
```

### Common View Patterns

```swift
// Pull to refresh
.refreshable {
    viewModel?.refresh()
}

// Search
.searchable(text: $searchText, prompt: "Search...")

// Swipe actions
.swipeActions(edge: .trailing) {
    Button(role: .destructive) { } label: { Label("Delete", systemImage: "trash") }
}

// Confirmation dialog
.confirmationDialog("Title", isPresented: $showDialog) {
    Button("Confirm", role: .destructive) { }
    Button("Cancel", role: .cancel) { }
}

// Toolbar
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button { } label: { Image(systemName: "plus") }
    }
}
```

### Form Validation Pattern

```swift
@Observable
class FormViewModel {
    var text = ""

    var isValid: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var parsedURL: URL? {
        URL(string: text)
    }
}

// In view
Button("Save") { viewModel.save() }
    .disabled(!viewModel.isValid)
```

---

## Summary

Phase 3 taught you:

1. **Coordinator Pattern**: Centralized navigation management
2. **@Observable**: Swift 5.9's reactive state management
3. **NavigationStack**: Type-safe programmatic navigation
4. **MVVM**: Separating UI from business logic
5. **Sheet Presentation**: Modal forms and dialogs
6. **Swipe Actions**: iOS-style list interactions
7. **Form Validation**: User input handling
8. **Preview Patterns**: Testing UI in isolation

The app now has complete navigation between all screens, proper state management, and a clean separation of concerns. Each view is focused on display, each ViewModel handles logic, and the Coordinator manages flow.

---

## What's Next

In **Phase 4**, you'll add:
- Share Extension (add items from other apps)
- Home Screen Widgets
- Settings and preferences
- CloudKit sync preparation

---

*The code is complete. Run the app and explore!*
