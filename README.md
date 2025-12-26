# Stash My Stuff

> Track the journey from 'want' to 'have' to 'loved it'.

A curated wishlist & lifecycle tracker for the things you want to cook, read, watch, listen to, wear, and own. Built natively for iOS, iPadOS, and macOS — designed with Apple's Liquid Glass aesthetic.

**No subscriptions. No third-party servers. Just your stuff, beautifully organized.**

---

## Project Status

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 0 | ✅ Complete | Foundation & Project Setup |
| Phase 1 | 🔲 Pending | Data Layer & Core Models |
| Phase 2 | 🔲 Pending | Design System & UI Components |
| Phase 3 | 🔲 Pending | Core App Screens |
| Phase 4 | 🔲 Pending | Share Extension & Metadata |
| Phase 5 | 🔲 Pending | CloudKit Sync & Paid Features ⚠️ |
| Phase 6 | 🔲 Pending | Polish, Widgets & Launch Prep |

> ⚠️ **Phase 5 requires a paid Apple Developer account** ($99/year) for iCloud sync, push notifications, and App Store distribution. All other phases work with a free Apple ID.

See [DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md) for detailed roadmap.

---

## What It Does

Save links from anywhere via the share sheet. The app auto-extracts titles, images, and suggests tags. Track each item through its lifecycle with category-specific flags.

### Categories

| Category | Lifecycle Flags |
|----------|-----------------|
| 🍳 **Recipes** | Cooked → Would make again → Written in recipe book |
| 📚 **Books** | Bought → Read → Rating |
| 🎬 **Movies** | Watched → Rating |
| 🎵 **Music** | Listened → Want to purchase → Purchased |
| 👕 **Clothes** | Want to buy → Bought |
| 🏠 **Furniture** | Inspiration → Want to buy → Bought |
| 🔗 **Links** | Read → Reference (catch-all) |

### Key Features

- **Share Sheet Extension** — Save from any app with one tap
- **Smart Views** — "Bandcamp Friday Queue", "To Read", "Uncooked Recipes"
- **Bandcamp Friday Notifications** — Reminder on purchase days with queue count ⚠️
- **Multi-User Sync** — Shared library via iCloud ⚠️
- **Liquid Glass Design** — iOS/macOS 26 native aesthetic

> ⚠️ Features marked require paid Apple Developer account

---

## Tech Stack

- **SwiftUI** — iOS 26+, macOS 26+
- **SwiftData** — Local persistence (CloudKit sync optional)
- **CloudKit** — Private + Shared databases ⚠️
- **LinkPresentation** — Auto metadata extraction

---

## Getting Started

### Requirements

- Xcode 16.0+ (beta)
- iOS 26.0+ / macOS 26.0+ SDK
- Apple ID (free) for local development
- Apple Developer Program ($99/year) for Phase 5 features

### Setup

1. Clone the repository
2. Open `StashMyStuff.xcodeproj` in Xcode
3. Select your development team in Signing & Capabilities
4. Build and run (`⌘R`)

### Project Structure

```
StashMyStuff/
├── App/              # Entry point, DI container
├── Models/           # SwiftData models
├── Views/            # SwiftUI views
├── ViewModels/       # View logic
├── Services/         # Business logic
├── DesignSystem/     # Reusable UI components
├── Coordinators/     # Navigation management
└── Utilities/        # Extensions, helpers
```

---

## Documentation

- [PROJECT_BRIEF.md](./PROJECT_BRIEF.md) — Full specification
- [DEVELOPMENT_PLAN.md](./DEVELOPMENT_PLAN.md) — Phased roadmap
- [CLAUDE.md](./CLAUDE.md) — AI assistant guidelines

---

## License

MIT License — See [LICENSE](./LICENSE) section below.

Copyright (c) 2025 Tomas Juergensen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
