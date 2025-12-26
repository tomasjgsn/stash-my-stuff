# Stash My Stuff — Project Brief

## Executive Summary

**Stash My Stuff** is a curated wishlist & lifecycle tracker for the things you want to cook, read, watch, listen to, wear, and own. Built natively for iOS, iPadOS, and macOS with iCloud sync and shared access — designed with Apple's Liquid Glass aesthetic.

This is not a generic bookmark app. It's a **personal curation system** where every saved item has a journey: discovered → acquired → experienced → remembered.

---

## Vision Statement

> "Track the journey from 'want' to 'have' to 'loved it'."

---

## Core Use Cases & Categories

The app is built around **7 categories**, each with custom lifecycle flags:

### 1. Recipes
**Sources:** Instagram, web links, NYT Cooking, YouTube, etc.

| Flag | Icon | Description |
|------|------|-------------|
| `hasBeenCooked` | 🍳 | Made this recipe |
| `wouldCookAgain` | ⭐ | Worth repeating |
| `writtenIntoRecipeBook` | 📖 | Transcribed to physical book |

**Smart Views:**
- "To Cook" — not yet cooked
- "Favorites" — would cook again
- "Transcribed" — in the book

---

### 2. Books
**Sources:** Goodreads, Amazon, Bookshop, library links

| Flag | Icon | Description |
|------|------|-------------|
| `hasBought` | 📦 | Purchased/obtained |
| `hasRead` | ✓ | Finished reading |
| `rating` | ★★★★☆ | Optional 1-5 rating |

**Smart Views:**
- "To Buy" — want but don't own
- "To Read" — own but haven't read
- "Finished" — completed

---

### 3. Movies & TV
**Sources:** Letterboxd, IMDb, streaming service links

| Flag | Icon | Description |
|------|------|-------------|
| `hasWatched` | 👁 | Watched it |
| `rating` | ★★★★☆ | Optional 1-5 rating |

**Smart Views:**
- "Watchlist" — not yet watched
- "Watched" — seen it

---

### 4. Music
**Sources:** Bandcamp, Spotify, Apple Music, SoundCloud, YouTube

| Flag | Icon | Description |
|------|------|-------------|
| `hasListened` | 🎧 | Listened to it |
| `wantToPurchase` | 💸 | Want to buy (vinyl, digital) |
| `hasPurchased` | ✓ | Already bought |

**Smart Views:**
- "Bandcamp Friday Queue" — want to purchase, not yet purchased
- "Purchased" — owned
- "To Listen" — saved but not listened

**Special Feature:** Bandcamp Friday reminder notification

**2026 Bandcamp Friday Dates:**
- Feb 6, Mar 6, May 1, Aug 7, Sep 4, Oct 2, Nov 6, Dec 4
- App will send push notification on these mornings with queue count

---

### 5. Clothes
**Sources:** Brand websites, Instagram, shopping apps

| Flag | Icon | Description |
|------|------|-------------|
| `wantToBuy` | 👀 | On the wishlist |
| `hasBought` | 🛍 | Purchased |

**Smart Views:**
- "Wishlist" — want to buy
- "Bought" — purchased

**Metadata:** Size notes, price, season

---

### 6. Furniture & Home
**Sources:** Design blogs, Instagram, retail sites

| Flag | Icon | Description |
|------|------|-------------|
| `isInspiration` | 💡 | Just for inspiration/mood |
| `wantToBuy` | 🏠 | Actually want to purchase |
| `hasBought` | ✓ | Purchased |

**Smart Views:**
- "Inspiration Board" — mood/reference only
- "Shopping List" — intend to buy
- "Purchased" — bought

**Metadata:** Room assignment, price, dimensions notes

---

### 7. Links (Misc)
**Sources:** Anything — articles, tools, references, interesting finds

| Flag | Icon | Description |
|------|------|-------------|
| `hasRead` | ✓ | Read/reviewed it |
| `isReference` | 📌 | Keep as reference |

**Smart Views:**
- "Unread" — saved but not read
- "References" — pinned for later

**Use case:** The catch-all for anything that doesn't fit recipes, books, movies, music, clothes, or furniture. Articles, dev tools, random interesting sites, resources, etc.

---

## Data Model

```swift
// Category defines available flags
enum Category: String, Codable, CaseIterable {
    case recipes
    case books
    case movies
    case music
    case clothes
    case furniture
    case links      // Catch-all for misc items
}

@Model class StashItem {
    var id: UUID
    var category: Category

    // Core metadata (auto-extracted)
    var title: String
    var url: URL?
    var source: String?           // "instagram.com", "nytcooking.com"
    var thumbnailData: Data?
    var notes: String?

    // Universal flags
    var isFavorite: Bool
    var isArchived: Bool

    // Category-specific flags (stored as JSON for flexibility)
    var flags: [String: Bool]     // e.g., ["hasBeenCooked": true, "wouldCookAgain": false]
    var rating: Int?              // 1-5 stars (optional)

    // Organization
    var tags: [Tag]
    var addedBy: String?          // User attribution for shared libraries

    // Timestamps
    var createdAt: Date
    var modifiedAt: Date
}

@Model class Tag {
    var name: String
    var color: String
    var items: [StashItem]
}
```

### Flag Configuration per Category

```swift
struct CategoryConfig {
    let category: Category
    let icon: String
    let flags: [FlagDefinition]
}

struct FlagDefinition {
    let key: String
    let label: String
    let icon: String
    let isToggle: Bool  // vs. rating/multi-state
}

let categoryConfigs: [CategoryConfig] = [
    CategoryConfig(
        category: .recipes,
        icon: "fork.knife",
        flags: [
            FlagDefinition(key: "hasBeenCooked", label: "Cooked", icon: "flame"),
            FlagDefinition(key: "wouldCookAgain", label: "Would make again", icon: "star"),
            FlagDefinition(key: "writtenIntoRecipeBook", label: "In recipe book", icon: "book")
        ]
    ),
    CategoryConfig(
        category: .books,
        icon: "book",
        flags: [
            FlagDefinition(key: "hasBought", label: "Bought", icon: "bag"),
            FlagDefinition(key: "hasRead", label: "Read", icon: "checkmark")
        ]
    ),
    // ... etc
]
```

---

## User Interface

### Primary Navigation

```
┌─────────────────────────────────────────────────────────┐
│                                                          │
│   ┌────────────────────────────────────────────────┐    │
│   │  🔍 Search                                      │    │
│   └────────────────────────────────────────────────┘    │
│                                                          │
│   CATEGORIES                                             │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐               │
│   │  🍳      │ │  📚      │ │  🎬      │               │
│   │ Recipes  │ │  Books   │ │  Movies  │               │
│   │    12    │ │    8     │ │    24    │               │
│   └──────────┘ └──────────┘ └──────────┘               │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐               │
│   │  🎵      │ │  👕      │ │  🏠      │               │
│   │  Music   │ │ Clothes  │ │ Furniture│               │
│   │    31    │ │    5     │ │    7     │               │
│   └──────────┘ └──────────┘ └──────────┘               │
│   ┌──────────┐                                          │
│   │  🔗      │                                          │
│   │  Links   │  ← Misc/catch-all                        │
│   │    19    │                                          │
│   └──────────┘                                          │
│                                                          │
│   SMART VIEWS                                            │
│   ├─ 🛒 Bandcamp Friday Queue (4)                       │
│   ├─ 📖 To Read (6)                                     │
│   ├─ 🍳 Uncooked Recipes (8)                            │
│   └─ ⭐ All Favorites (15)                              │
│                                                          │
│   SHARED LIBRARY                                         │
│   └─ 👥 Our Library (47)                                │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Category View (e.g., Recipes)

```
┌─────────────────────────────────────────────────────────┐
│  ← Recipes                              Filter ▼  + Add │
│─────────────────────────────────────────────────────────│
│                                                          │
│  FILTER TABS                                             │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐       │
│  │   All   │ │ To Cook │ │  Made   │ │In Book  │       │
│  │   (12)  │ │   (5)   │ │   (7)   │ │   (3)   │       │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘       │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ ┌─────────┐                                        │ │
│  │ │ 📷      │  Crispy Gochujang Chicken             │ │
│  │ │  IMG    │  nytcooking.com                       │ │
│  │ │         │  ┌────┐ ┌────┐ ┌────┐                 │ │
│  │ └─────────┘  │ 🍳 │ │ ⭐ │ │ 📖 │                 │ │
│  │              └────┘ └────┘ └────┘                 │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │ ┌─────────┐                                        │ │
│  │ │ 📷      │  Cacio e Pepe                         │ │
│  │ │  IMG    │  instagram.com/@bonappetit            │ │
│  │ │         │  ┌────┐ ┌────┐ ┌────┐                 │ │
│  │ └─────────┘  │ ○  │ │ ○  │ │ ○  │  ← not yet      │ │
│  │              └────┘ └────┘ └────┘                 │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Item Detail View

```
┌─────────────────────────────────────────────────────────┐
│  ← Back                                    ⋯  Share  ✎  │
│─────────────────────────────────────────────────────────│
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │                                                    │ │
│  │              [ Hero Image ]                        │ │
│  │                                                    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  Crispy Gochujang Chicken                               │
│  nytcooking.com • Added Dec 15                          │
│  Added by: Jess                                          │
│                                                          │
│  ─────────────────────────────────────────────────────  │
│                                                          │
│  FLAGS                                                   │
│  ┌───────────────────┐  ┌───────────────────┐          │
│  │  🍳 Cooked        │  │  ⭐ Would repeat  │          │
│  │      [ON]         │  │      [ON]         │          │
│  └───────────────────┘  └───────────────────┘          │
│  ┌───────────────────┐                                  │
│  │  📖 In book       │                                  │
│  │      [OFF]        │                                  │
│  └───────────────────┘                                  │
│                                                          │
│  ─────────────────────────────────────────────────────  │
│                                                          │
│  NOTES                                                   │
│  "Doubled the gochujang, served with rice"              │
│                                                          │
│  ─────────────────────────────────────────────────────  │
│                                                          │
│  TAGS                                                    │
│  ┌────────┐ ┌────────┐ ┌────────┐                      │
│  │ Korean │ │Weeknight│ │ Spicy  │                      │
│  └────────┘ └────────┘ └────────┘                      │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │         [ Open Original Link ]                     │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Share Sheet Flow

```
1. User shares link from Safari/Instagram/etc.
2. Share extension opens:

┌─────────────────────────────────────────────────────────┐
│                     Add to Stash                        │
│─────────────────────────────────────────────────────────│
│                                                          │
│  ┌─────────┐  Crispy Gochujang Chicken                 │
│  │  📷     │  nytcooking.com                           │
│  └─────────┘  (auto-extracted)                         │
│                                                          │
│  CATEGORY                                                │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐          │
│  │🍳 *    │ │ 📚     │ │ 🎬     │ │ 🎵     │          │
│  │Recipe  │ │ Book   │ │ Movie  │ │ Music  │          │
│  └────────┘ └────────┘ └────────┘ └────────┘          │
│  ┌────────┐ ┌────────┐ ┌────────┐                      │
│  │ 👕     │ │ 🏠     │ │ 🔗     │                      │
│  │Clothes │ │Furniture│ │ Links  │                      │
│  └────────┘ └────────┘ └────────┘                      │
│                                                          │
│  * Auto-detected from URL                               │
│                                                          │
│  QUICK TAGS (optional)                                   │
│  ┌────────┐ ┌────────┐ ┌────────┐                      │
│  │+ Korean│ │+ Spicy │ │+ New   │   ← suggested        │
│  └────────┘ └────────┘ └────────┘                      │
│                                                          │
│            [ Cancel ]     [ Save ]                      │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## Liquid Glass Design System

### Visual Tokens

| Token | Value |
|-------|-------|
| Glass blur | `Material.ultraThinMaterial` with 0.8 opacity |
| Card radius | 20pt |
| Shadow | 0, 8, 24 @ 0.12 opacity |
| Accent | System tint, adapts to category |
| Typography | SF Pro Rounded for headers |

### Category Colors

| Category | Accent Color |
|----------|--------------|
| Recipes | Orange |
| Books | Indigo |
| Movies | Purple |
| Music | Pink |
| Clothes | Teal |
| Furniture | Brown |
| Links | Gray |

### Animations

- Card tap: Spring with 0.5 damping
- Flag toggle: Scale bounce + haptic
- List reorder: Fluid drag with glass trail

---

## Technical Architecture

### Stack

| Layer | Technology | Paid Account Required |
|-------|------------|----------------------|
| UI | SwiftUI (iOS 26+, macOS 26+) | No |
| Data | SwiftData | No |
| Sync | CloudKit Private + Shared databases | **Yes** |
| Push | Apple Push Notification service | **Yes** |
| Metadata | LinkPresentation framework | No |
| Extensions | ShareExtension, WidgetKit | Partial* |

> *Share Extension data sharing via App Groups requires paid account. Basic extension UI works without.

### Project Structure

```
stash-my-stuff/
├── StashMyStuff/
│   ├── App/
│   │   ├── StashMyStuffApp.swift
│   │   └── AppState.swift
│   ├── Models/
│   │   ├── StashItem.swift
│   │   ├── Category.swift
│   │   ├── Tag.swift
│   │   └── CategoryConfig.swift
│   ├── Views/
│   │   ├── Home/
│   │   │   ├── HomeView.swift
│   │   │   └── CategoryGridView.swift
│   │   ├── Category/
│   │   │   ├── CategoryListView.swift
│   │   │   └── FilterTabsView.swift
│   │   ├── Detail/
│   │   │   ├── ItemDetailView.swift
│   │   │   └── FlagToggleView.swift
│   │   ├── Capture/
│   │   │   └── AddItemSheet.swift
│   │   └── Components/
│   │       ├── GlassCard.swift
│   │       ├── TagChip.swift
│   │       └── FlagButton.swift
│   ├── Services/
│   │   ├── MetadataService.swift
│   │   ├── CategoryDetectionService.swift
│   │   └── CloudKitSharingService.swift
│   └── DesignSystem/
│       ├── LiquidGlass.swift
│       └── CategoryTheme.swift
├── StashShareExtension/
│   ├── ShareViewController.swift
│   └── ShareView.swift
├── StashWidgets/
│   └── BandcampFridayWidget.swift
└── StashMyStuff.xcodeproj
```

---

## Implementation Phases

> **Note:** See [DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md) for detailed phase breakdown with milestones.

### Phases 0-4: Core App (Free Apple ID)
- [x] Phase 0: Project setup, architecture, CI/CD
- [ ] Phase 1: Data layer & SwiftData models
- [ ] Phase 2: Design system & UI components
- [ ] Phase 3: Core screens (Home, Category, Detail)
- [ ] Phase 4: Share Extension & metadata extraction

### Phase 5: Paid Features ⚠️
> **Requires Apple Developer Program ($99/year)**

- [ ] CloudKit sync between devices
- [ ] Push notifications (Bandcamp Friday reminders)
- [ ] App Groups (Share Extension data sharing)
- [ ] Shared libraries with other users
- [ ] App Store distribution

### Phase 6: Polish & Launch
- [ ] Widgets
- [ ] Platform-specific refinements
- [ ] Accessibility
- [ ] App Store preparation

---

## Completion Behavior

When an item is "completed" (all lifecycle flags checked — e.g., book read, furniture bought, recipe cooked & transcribed):

- **Stays visible** with a subtle "completed" badge
- **Sorted to bottom** of list views to separate active/pending items from completed
- No hidden archive — everything remains accessible
- Smart views auto-exclude completed items (e.g., "To Read" won't show books already read)

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Share-to-save | < 2 taps, < 3 seconds |
| Flag toggle | Single tap, instant feedback |
| Sync latency | < 5 seconds |
| Category auto-detection | 80%+ accuracy |

---

## Next Steps

1. ~~Create Xcode multiplatform project~~ ✅
2. Implement SwiftData models with category/flag system
3. Build Liquid Glass component library
4. Implement Home → Category → Detail navigation
5. Build Share Extension (basic UI)
6. *Later: Configure CloudKit (requires paid account)*
