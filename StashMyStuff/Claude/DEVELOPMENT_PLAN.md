# Stash My Stuff — Development Plan

> A bulletproof roadmap to ship a polished, production-ready app.

---

## Current Status

| Phase | Progress | Status |
|-------|----------|--------|
| Phase 0: Foundation | 100% | ✅ Complete |
| Phase 1: Data Layer | 100% | ✅ Complete |
| Phase 2: Design System | 0% | 📍 **Up Next** |
| Phase 3: Core Screens | 0% | Pending |
| Phase 4: Share Extension | 0% | Pending |
| Phase 5: CloudKit Sync ⚠️ | 0% | Pending |
| Phase 6: Polish & Launch | 0% | Pending |

**Last Updated:** December 27, 2025

---

## Overview

This plan breaks down the Stash My Stuff project into **7 phases** with clear milestones, deliverables, and success criteria. Each phase builds on the previous, ensuring you always have a working app while progressively adding features.

> **Note:** Phase 5 (CloudKit Sync & Paid Features) requires an Apple Developer Program membership ($99/year). All other phases work with a free Apple ID.

**Key Principles:**
- Ship working increments — every phase ends with a testable build
- Test early, test often — unit tests from day one
- Design system first — components before screens
- Data layer before UI — models drive everything

---

## Phase 0: Foundation & Project Setup
**Goal:** Establish a rock-solid project structure with CI, testing, and proper architecture.

### Milestones

#### 0.1 — Xcode Project Configuration
- [x] Create multiplatform app (iOS 26+, macOS 26+) using SwiftUI lifecycle
- [x] Configure proper bundle identifiers: `com.stashmystuff.app`
- [x] Set up App Groups for Share Extension data sharing
- [x] Add Share Extension target (`StashShareExtension`)
- [x] Add Widget Extension target (`StashWidgets`)
- [x] Configure entitlements for iCloud (CloudKit)

#### 0.2 — Architecture Setup
- [x] Implement MVVM-C (Model-View-ViewModel with Coordinator) pattern
- [x] Create folder structure matching PROJECT_BRIEF specification
- [x] Set up dependency injection container (Swift native, no external libs)
- [x] Configure SwiftLint for code consistency
- [x] Add SwiftFormat for automated formatting

#### 0.3 — Testing Infrastructure
- [x] Create unit test target with XCTest
- [x] Create UI test target
- [x] Set up test utilities and mock factories
- [x] Configure code coverage reporting (target: 70%+)

#### 0.4 — Version Control & CI
- [x] Set up Git branching strategy (main → develop → feature/*)
- [x] Configure GitHub Actions for:
  - Build validation on PR
  - Unit test execution
  - SwiftLint checks
- [x] Create PR template with checklist

### Deliverable
A clean, buildable Xcode project with all targets configured, running on Simulator.

### Success Criteria
- [x] App launches on iOS Simulator
- [x] App launches on macOS
- [x] Share Extension appears in share sheet
- [x] All tests pass (even if just placeholder tests)
- [x] CI pipeline runs successfully

---

## Phase 1: Data Layer & Core Models ✅
**Status:** COMPLETE (December 2025)
**Goal:** Build the complete data foundation with SwiftData and local persistence.

### Milestones

#### 1.1 — SwiftData Models
- [x] Implement `StashItem` model with all properties from spec
- [x] Implement `Tag` model with bidirectional relationship
- [x] Implement `Category` enum with CaseIterable
- [x] Create `CategoryConfig` and `FlagDefinition` structures
- [x] Add computed properties for lifecycle state detection

```swift
// Key model features to implement:
extension StashItem {
    var isCompleted: Bool { /* check all flags for category */ }
    var lifecycleProgress: Double { /* 0.0 - 1.0 */ }
    var availableFlags: [FlagDefinition] { /* from CategoryConfig */ }
}
```

#### 1.2 — Category Configuration System
- [x] Define all 10 category configurations with flags
- [x] Implement flag validation per category
- [x] Create category-specific computed properties
- [x] Build flag toggle logic with proper state management

#### 1.3 — Data Layer Services
- [x] Create `StashRepository` protocol and implementation
- [x] Implement CRUD operations with SwiftData
- [x] Add query methods for Smart Views:
  - `fetchUncooked()` — recipes not yet cooked
  - `fetchToRead()` — books owned but unread
  - `fetchBandcampQueue()` — music to purchase
  - `fetchByCategory(_:)` — filtered by category
  - `fetchFavorites()` — all favorites across categories
- [x] Implement sorting: by date added, by completion status
- [x] Add full-text search across title, notes, tags

#### 1.4 — Data Validation & Migration
- [x] Add model validation (required fields, URL format)
- [x] Create schema versioning strategy for future migrations
- [x] Implement data integrity checks

### Deliverable
Complete data layer with unit tests, capable of CRUD operations and all Smart View queries.

### Success Criteria
- [x] All model unit tests pass (25 tests across 5 test suites)
- [x] Can create, read, update, delete items
- [x] Smart View queries return correct results
- [x] Search works across all searchable fields
- [x] 80%+ code coverage on data layer

---

## Phase 2: Design System & UI Components
**Goal:** Build the Liquid Glass design system and reusable components before any screens.

### Milestones

#### 2.1 — Design Tokens
- [ ] Create `DesignTokens` enum/struct with all values:
  - Colors (category accents, semantic colors)
  - Glass (Material types for glass effects)
  - Typography (SF Pro Rounded scales)
  - Spacing (consistent 4pt grid)
  - Radii (card: 20pt, button: 12pt)
  - Shadows (for non-glass elements)

#### 2.2 — View Modifiers & Effects ✓
- [x] Use iOS 26's native `.glassEffect()` modifier
- [x] Create `GlassCardModifier` and `InteractiveGlassModifier`
- [x] Build `CategoryAccentModifier` and `CategoryBadgeModifier`
- [x] Implement conditional modifiers (`.when()`, `.whenElse()`, `.ifLet()`)
- [x] Create `FavoriteBadgeModifier` with glass effect
- [x] Build `RotatingGlowModifier` with tonal rainbow animation
- [x] Add `FlowLayout` custom layout for badge wrapping
- [x] Ensure all modifiers respect system appearance and accessibility

```swift
// Native iOS 26 Liquid Glass
VStack { content }
    .glassCard()                                    // Glass card with padding
    .glassButton()                                  // Interactive glass for buttons

// Conditional modifiers
view.when(condition) { $0.bold() }
view.whenElse(flag, then: { ... }, else: { ... })
view.ifLet(optional) { view, value in ... }

// Badge modifiers
Image("thumbnail").favoriteBadge(isFavorite: true)
Card().rotatingGlow(isNew, category: .recipe)       // Tonal rainbow animation
```

#### 2.3 — Core Components
- [ ] `CategoryIcon` — SF Symbol with category accent color
- [ ] `FlagButton` — Toggle with icon, label, haptic feedback
- [ ] `RatingView` — 1-5 star picker with half-star support
- [ ] `TagChip` — Pill with color and remove action
- [ ] `TagInput` — Autocomplete tag entry field
- [ ] `ItemThumbnail` — Async image with placeholder and error state
- [ ] `SourceBadge` — Domain name with favicon

#### 2.4 — List Components
- [ ] `StashItemRow` — Card for list display with thumbnail, title, flags
- [ ] `CategoryCard` — Grid item for home view with icon and count
- [ ] `SmartViewRow` — List item for smart view navigation
- [ ] `FilterTab` — Segmented control style filter

#### 2.5 — Animation & Haptics
- [ ] Define spring animations for interactions
- [ ] Implement flag toggle animation (scale + check)
- [ ] Add haptic feedback service (toggle, success, error)
- [ ] Create list reorder drag animation

### Deliverable
A component library with SwiftUI Previews demonstrating all components in isolation.

### Success Criteria
- [ ] All components have SwiftUI Previews
- [ ] Components work in both light and dark mode
- [ ] Components scale properly for Dynamic Type
- [ ] Haptics fire correctly on device
- [ ] No visual glitches in any component

---

## Phase 3: Core App Screens
**Goal:** Build the main app flow: Home → Category → Detail with full navigation.

### Milestones

#### 3.1 — Navigation Architecture
- [ ] Implement `NavigationStack` with typed destinations
- [ ] Create `AppCoordinator` for navigation state
- [ ] Handle deep linking structure for future use
- [ ] Platform-specific navigation:
  - iOS: Stack-based with tab bar potential
  - macOS: Sidebar + detail pattern

#### 3.2 — Home Screen
- [ ] Category grid (10 categories with counts)
- [ ] Smart Views section with dynamic counts
- [ ] Search bar with instant filtering
- [ ] Pull-to-refresh for sync status
- [ ] Add button (floating or toolbar)

#### 3.3 — Category List Screen
- [ ] Filter tabs (All, and category-specific filters)
- [ ] Item list with `StashItemRow` cards
- [ ] Sort options (date added, alphabetical, completion)
- [ ] Empty state with helpful message
- [ ] Swipe actions (delete, favorite, quick flag toggle)

#### 3.4 — Item Detail Screen
- [ ] Hero image with async loading
- [ ] Title, source, date added metadata
- [ ] Flag toggles specific to category
- [ ] Rating picker (where applicable)
- [ ] Notes field (expandable text editor)
- [ ] Tags display and edit
- [ ] "Open Original Link" button
- [ ] Edit mode for title/metadata changes
- [ ] Delete confirmation

#### 3.5 — Add/Edit Item Sheet
- [ ] Manual entry form
- [ ] Category picker with visual icons
- [ ] Title and URL input
- [ ] Tag selection/creation
- [ ] Notes field
- [ ] Validation and error states

### Deliverable
Fully navigable app with all core screens. Data persists locally.

### Success Criteria
- [ ] Can navigate Home → Category → Detail and back
- [ ] Can create new items via Add sheet
- [ ] Can edit and delete items
- [ ] Can toggle flags and see updates in lists
- [ ] Can filter and search items
- [ ] UI tests cover critical navigation paths

---

## Phase 4: Share Extension & Metadata
**Goal:** Enable the core use case — saving links from any app with auto-extraction.

### Milestones

#### 4.1 — Share Extension UI
- [ ] Create minimal SwiftUI share view
- [ ] Display extracted metadata preview
- [ ] Category picker (horizontal scroll)
- [ ] Auto-detect category from URL (80%+ accuracy target)
- [ ] Quick tag suggestions
- [ ] Save and Cancel buttons
- [ ] Loading and error states

#### 4.2 — Metadata Extraction Service
- [ ] Implement `MetadataService` using LinkPresentation
- [ ] Extract: title, description, hero image, icon
- [ ] Handle timeout gracefully (3 second limit)
- [ ] Cache extracted metadata
- [ ] Fallback values for extraction failures

#### 4.3 — Category Auto-Detection
- [ ] Build `CategoryDetectionService` with URL pattern matching
- [ ] Domain mappings:
  - `nytcooking.com`, `allrecipes.com` → Recipes
  - `goodreads.com`, `amazon.com/dp/` (books) → Books
  - `imdb.com`, `letterboxd.com`, `justwatch.com` → Movies & TV
  - `bandcamp.com`, `spotify.com`, `soundcloud.com` → Music
  - `*.myshopify.com`, fashion domains, brand sites → Clothes
  - `wayfair.com`, `ikea.com`, design blogs → Home
  - `medium.com`, `substack.com`, news domains → Articles
  - `apple.com/podcasts`, `spotify.com/show` → Podcasts
  - `airbnb.com`, `tripadvisor.com`, travel blogs → Trips
  - All others → Backpack (catch-all)
- [ ] Confidence scoring for auto-detection
- [ ] User can always override

#### 4.4 — App Group Data Sharing
- [ ] Configure shared container between app and extension
- [ ] Share SwiftData store via App Group
- [ ] Ensure extension writes sync to main app
- [ ] Handle concurrent access safely

### Deliverable
Working share extension that saves links with metadata to the main app.

### Success Criteria
- [ ] Share from Safari adds item to app
- [ ] Share from any app (Safari, Mail, Notes, etc.) adds item
- [ ] Metadata (title, image) extracts in < 3 seconds
- [ ] Category auto-detects correctly for known domains (80%+ accuracy)
- [ ] < 2 taps to save (category auto-selected)

---

## Phase 4.5: Custom UI Design with Figma
**Goal:** Elevate the app's visual design from functional to distinctive using Figma.

> **Why This Phase?** Most developer-designed apps look generic. This phase takes a step back from code to focus on visual design, creating a polished, distinctive UI inspired by top agencies like [Ragged Edge](https://raggededge.com/).

### Prerequisites
- Working app from Phases 1-4
- Free Figma account ([figma.com](https://figma.com))
- Design inspiration research completed

### Figma Free Plan Strategy

The free tier limits you to 3 files. Use them strategically:

| File | Purpose |
|------|---------|
| 1. Design System | Colors, typography, components |
| 2. iOS Screens | All app screen designs |
| 3. Prototype | Interactive flows |

### Milestones

#### 4.5.1 — Figma Fundamentals
- [ ] Set up Figma account and workspace
- [ ] Learn frames, auto layout, and components
- [ ] Create file structure for design system
- [ ] Build first reusable components

#### 4.5.2 — Design System File
- [ ] Define refined color palette (warmer, more sophisticated)
- [ ] Create typography scale with personality
- [ ] Build all button components (with states)
- [ ] Build card components (glass variants)
- [ ] Build list row components
- [ ] Build form elements

#### 4.5.3 — Typography & Color Refinement
- [ ] Select or customize typefaces
- [ ] Create warm, cohesive color palette
- [ ] Ensure accessibility (contrast ratios)
- [ ] Define dark mode variants

#### 4.5.4 — Screen Designs
- [ ] Redesign Home screen with improved hierarchy
- [ ] Redesign Category list with better visual rhythm
- [ ] Redesign Item detail with cleaner layout
- [ ] Design Add/Edit sheets
- [ ] Design empty states
- [ ] Design error states

#### 4.5.5 — Prototyping & Handoff
- [ ] Create interactive prototype for key flows
- [ ] Test flows for usability
- [ ] Export assets for Xcode
- [ ] Document specifications for SwiftUI updates

### Design Principles (Ragged Edge-Inspired)

| Principle | Application |
|-----------|-------------|
| Restrained elegance | Generous whitespace, no visual clutter |
| Custom typography | SF Pro Rounded + distinctive accents |
| Warm color palette | Tinted neutrals, sophisticated category colors |
| Grid discipline | Consistent 8pt grid, modular layouts |
| Meaningful motion | Purpose-driven animations only |
| Data as story | "12 uncooked recipes" not just "12 items" |

### Deliverable
Complete Figma design system and screen designs ready for implementation.

### Success Criteria
- [ ] Design system file with all reusable components
- [ ] All core screens designed in Figma
- [ ] Interactive prototype for 3 key user flows
- [ ] Designs work in both light and dark mode
- [ ] All colors pass WCAG accessibility contrast checks
- [ ] Assets exported and ready for Xcode

> **Full Lesson Plan**: See `Lessons/Phase4.5-UI-Design/README.md`

---

## Phase 5: CloudKit Sync & Paid Features ⚠️

> **⚠️ REQUIRES PAID APPLE DEVELOPER ACCOUNT ($99/year)**
>
> This phase cannot be completed with a free Apple ID. Features include:
> - iCloud sync between devices
> - Push notifications (Bandcamp Friday reminders)
> - App Groups (Share Extension data sharing)
> - Shared libraries with other users
> - App Store distribution
>
> You can skip this phase and still have a fully functional local-only app.

**Goal:** Enable iCloud sync and shared libraries between users.

### Prerequisites
- [ ] Join Apple Developer Program ($99/year)
- [ ] Configure App Store Connect account
- [ ] Re-enable entitlements in Xcode (iCloud, Push Notifications, App Groups)

### Milestones

#### 5.1 — CloudKit Private Database
- [ ] Configure CloudKit container in App Store Connect
- [ ] Enable SwiftData + CloudKit sync
- [ ] Test sync between devices (iPhone ↔ Mac)
- [ ] Handle sync conflicts (last-write-wins or merge)
- [ ] Add sync status indicator in UI

#### 5.2 — Push Notifications
- [ ] Configure APNs (Apple Push Notification service)
- [ ] Implement Bandcamp Friday reminder notifications
- [ ] Schedule notifications for 2026 Bandcamp Friday dates
- [ ] Handle notification permissions gracefully

#### 5.3 — App Groups & Share Extension
- [ ] Re-enable App Groups entitlement
- [ ] Configure shared container between app and extension
- [ ] Share SwiftData store via App Group
- [ ] Ensure extension writes sync to main app
- [ ] Handle concurrent access safely

#### 5.4 — CloudKit Shared Database
- [ ] Create shared record zone for library sharing
- [ ] Implement invitation flow via `UICloudSharingController`
- [ ] Handle share acceptance
- [ ] Display participant list

#### 5.5 — Multi-User Features
- [ ] Add `addedBy` field population from CloudKit user
- [ ] Display attribution in item detail
- [ ] Create "Shared Library" section in Home
- [ ] Filter by "added by me" vs "added by others"
- [ ] Handle permissions (read/write sharing)

#### 5.6 — Sync UX
- [ ] Visual sync indicator (subtle, non-intrusive)
- [ ] Offline mode support
- [ ] Conflict resolution UI (rare cases)
- [ ] Retry logic for failed syncs

### Deliverable
App syncs across all user devices, sends push notifications, and supports shared libraries.

### Success Criteria
- [ ] Item created on iPhone appears on Mac within 5 seconds
- [ ] Bandcamp Friday notification received on scheduled dates
- [ ] Share Extension saves items that appear in main app
- [ ] Can invite another iCloud user to shared library
- [ ] Both users see each other's additions
- [ ] Works offline, syncs when back online
- [ ] No data loss during sync conflicts

---

## Phase 6: Polish, Widgets & Launch Prep
**Goal:** Add delight features, widgets, and prepare for App Store submission.

### Milestones

#### 6.1 — Bandcamp Friday Features
- [ ] Store 2026 Bandcamp Friday dates
- [ ] Implement local notification scheduling
- [ ] Create Bandcamp Friday widget (queue count)
- [ ] Widget taps open Bandcamp Queue smart view
- [ ] Notification includes actionable deep link

#### 6.2 — Platform-Specific Polish
**iOS/iPadOS:**
- [ ] iPad sidebar navigation
- [ ] Keyboard shortcuts on iPad
- [ ] Stage Manager support
- [ ] Widget gallery with multiple sizes

**macOS:**
- [ ] Native sidebar with disclosure groups
- [ ] Full keyboard navigation
- [ ] Menu bar commands (New Item, Search)
- [ ] Touch Bar support (if applicable)
- [ ] Proper window resizing behavior

#### 6.3 — Accessibility
- [ ] VoiceOver labels on all interactive elements
- [ ] Dynamic Type support verified
- [ ] Reduce Motion respect for animations
- [ ] Color contrast verification
- [ ] Full keyboard accessibility (macOS)

#### 6.4 — Performance & Quality
- [ ] Profile with Instruments (memory, CPU)
- [ ] Optimize image loading and caching
- [ ] Lazy loading for large lists
- [ ] Reduce app launch time (< 1 second target)
- [ ] Fix all compiler warnings
- [ ] Remove all debug code and print statements

#### 6.5 — App Store Preparation
- [ ] App icons for all platforms and sizes
- [ ] Screenshots for all device classes
- [ ] App Store description and keywords
- [ ] Privacy policy (no third-party data collection)
- [ ] TestFlight beta testing
- [ ] App Review guidelines compliance check

### Deliverable
A polished, release-ready app with widgets and all platform optimizations.

### Success Criteria
- [ ] 0 crashes in 1 week of beta testing
- [ ] Lighthouse accessibility score > 90
- [ ] Launch time < 1 second
- [ ] All TestFlight feedback addressed
- [ ] App Store submission accepted

---

## Development Best Practices

### Liquid Glass Design Guidelines (iOS 26+)

This app uses Apple's Liquid Glass design language. These guidelines are **mandatory** for all UI work.

**Core Principles:**

| Principle | Implementation |
|-----------|----------------|
| **Hierarchy** | Glass floats on navigation layer; content sits below |
| **Content-First** | UI recedes when users are reading/creating/watching |
| **Interactive Mode** | Always use `.interactive()` for tappable glass elements |
| **Accessibility** | Maintain contrast; support Dynamic Type; respect Reduce Motion |

**When to Use Glass:**
- Navigation controls, toolbars, floating buttons
- Cards that overlay content
- Interactive controls (buttons, toggles, list rows)

**When NOT to Use Glass:**
- Main content areas
- Background fills
- Every UI element (be selective)

**API Patterns:**
```swift
// Static glass card
.glassEffect(.regular, in: .rect(cornerRadius: 16))

// Interactive (buttons, tappable)
.glassEffect(.regular.interactive(), in: .capsule)

// Tinted (category colors)
.glassEffect(.regular.tint(.orange), in: .rect(cornerRadius: 16))

// Morphing animations
GlassEffectContainer {
    view.glassEffect(.regular, in: shape)
         .glassEffectID("id", in: namespace)
}
```

**Reference:** See `CLAUDE.md` for full guidelines and source links.

---

### Code Quality
- **No force unwraps** — Use proper optional handling
- **No stringly-typed code** — Use enums for categories, flags, etc.
- **Protocol-oriented design** — Abstract services behind protocols
- **Dependency injection** — No singletons, inject dependencies
- **Immutable by default** — Use `let` unless mutation required

### Testing Strategy
| Layer | Test Type | Coverage Target |
|-------|-----------|-----------------|
| Models | Unit tests | 90% |
| Services | Unit tests with mocks | 80% |
| ViewModels | Unit tests | 80% |
| Views | SwiftUI Previews + UI tests | Critical paths |
| Integration | End-to-end tests | Happy paths |

### Git Workflow
```
main (production)
  └── develop (integration)
        ├── feature/phase1-models
        ├── feature/phase2-design-system
        └── bugfix/sync-conflict
```

- Feature branches for each milestone
- PR reviews required before merge
- Squash commits on merge to develop
- Tag releases on main

### Documentation
- README with setup instructions
- Inline code comments for complex logic
- SwiftUI Preview documentation strings
- Architecture decision records (ADRs) for major choices

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| CloudKit sync complexity | Start with private DB only, add sharing after stable |
| Share Extension memory limits | Minimal UI, async metadata fetch, timeout handling |
| iOS 26/macOS 26 beta issues | Test on each beta release, file radars early |
| Category auto-detection accuracy | Start with domain matching, add ML later if needed |
| Liquid Glass performance | Use native `.glassEffect()` and Materials which are GPU-optimized; profile early if issues arise |

---

## Definition of Done

An item is complete when:
- [ ] Code is written and self-reviewed
- [ ] Unit tests pass with target coverage
- [ ] UI works on all supported devices
- [ ] Accessibility verified with VoiceOver
- [ ] No compiler warnings
- [ ] PR approved and merged
- [ ] Tested on real device (not just simulator)

---

## Quick Reference

### File Locations
```
StashMyStuff/
├── Models/          ← SwiftData models
├── Views/           ← SwiftUI views by feature
├── ViewModels/      ← View state management
├── Services/        ← Business logic
├── DesignSystem/    ← Reusable components
└── Utilities/       ← Extensions, helpers
```

### Key Dependencies
- **SwiftUI** — All UI
- **SwiftData** — Persistence
- **CloudKit** — Sync
- **LinkPresentation** — Metadata
- **UserNotifications** — Bandcamp reminders

### Platform Targets
- iOS 26.0+
- iPadOS 26.0+
- macOS 26.0+

---

*This plan is your north star. Execute phase by phase, milestone by milestone. Ship often. Iterate based on testing. You've got this.*
