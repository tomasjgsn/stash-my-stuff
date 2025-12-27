//
//  StashRepository.swift
//  StashMyStuff
//
//  Repository pattern for StashItem persistence operations.
//  Uses SwiftData for storage with in-memory filtering for complex queries.
//

import Foundation
import SwiftData

protocol StashRepositoryProtocol {
    // CRUD operations
    func fetchAll() -> [StashItem]
    func fetchByCategory(_ category: Category) -> [StashItem]
    func save(_ item: StashItem)
    func delete(_ item: StashItem)

    // Smart View queries
    func fetchUncookedRecipes() -> [StashItem]
    func fetchToRead() -> [StashItem]
    func fetchBandcampQueue() -> [StashItem]
    func fetchUnwatchedMovies() -> [StashItem]

    // Advanced queries
    func fetchFavorites() -> [StashItem]
    func fetchByTag(_ tagName: String) -> [StashItem]
    func fetchRecent(days: Int) -> [StashItem]
    func fetchByCategory(_ category: Category, sortedBy: SortOption) -> [StashItem]
    func fetchCompleted(in category: Category) -> [StashItem]

    // Search
    func search(query: String) -> [StashItem]
}

// Sorting options for flexible queries
enum SortOption {
    case dateAdded
    case title
    case favorite
}

@Observable
class StashRepository: StashRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - CRUD Operations

    func fetchAll() -> [StashItem] {
        let descriptor = FetchDescriptor<StashItem>(
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        return (try? self.modelContext.fetch(descriptor)) ?? []
    }

    func fetchByCategory(_ category: Category) -> [StashItem] {
        // Use in-memory filtering for enum comparison (SwiftData predicate limitation)
        let allItems = self.fetchAll()
        return allItems.filter { $0.category == category }
    }

    func save(_ item: StashItem) {
        self.modelContext.insert(item)
        try? self.modelContext.save()
    }

    func delete(_ item: StashItem) {
        self.modelContext.delete(item)
        try? self.modelContext.save()
    }

    // MARK: - Smart View Queries

    func fetchUncookedRecipes() -> [StashItem] {
        let allItems = self.fetchAll()
        return allItems.filter { item in
            item.category == .recipe &&
                (item.flags["hasBeenCooked"] ?? false) == false
        }
    }

    func fetchToRead() -> [StashItem] {
        let allItems = self.fetchAll()
        return allItems.filter { item in
            item.category == .book &&
                (item.flags["hasBought"] ?? false) == true &&
                (item.flags["hasRead"] ?? false) == false
        }
    }

    func fetchBandcampQueue() -> [StashItem] {
        let allItems = self.fetchAll()
        return allItems.filter { item in
            item.category == .music &&
                (item.flags["wantToPurchase"] ?? false) == true &&
                (item.flags["hasBought"] ?? false) == false
        }
    }

    func fetchUnwatchedMovies() -> [StashItem] {
        let allItems = self.fetchAll()
        return allItems.filter { item in
            item.category == .movie &&
                (item.flags["hasWatched"] ?? false) == false
        }
    }

    // MARK: - Search

    func search(query: String) -> [StashItem] {
        let lowercased = query.lowercased()
        let allItems = self.fetchAll()

        return allItems.filter { item in
            item.title.lowercased().contains(lowercased)
                || item.notes.lowercased().contains(lowercased)
        }
    }

    // MARK: - Advanced Queries

    /// Fetch all favorited items across all categories
    func fetchFavorites() -> [StashItem] {
        let descriptor = FetchDescriptor<StashItem>(
            predicate: #Predicate { item in
                item.isFavorite == true
            },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        return (try? self.modelContext.fetch(descriptor)) ?? []
    }

    /// Fetch items that have a specific tag
    func fetchByTag(_ tagName: String) -> [StashItem] {
        let allItems = self.fetchAll()

        return allItems.filter { item in
            item.tags.contains { tag in
                tag.name.lowercased() == tagName.lowercased()
            }
        }
    }

    /// Fetch items added within the last N days
    func fetchRecent(days: Int) -> [StashItem] {
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return []
        }

        let descriptor = FetchDescriptor<StashItem>(
            predicate: #Predicate { item in
                item.dateAdded >= cutoffDate
            },
            sortBy: [SortDescriptor(\.dateAdded, order: .reverse)]
        )
        return (try? self.modelContext.fetch(descriptor)) ?? []
    }

    /// Fetch items in a category with flexible sorting
    func fetchByCategory(_ category: Category, sortedBy option: SortOption) -> [StashItem] {
        let items = self.fetchByCategory(category)

        switch option {
        case .dateAdded:
            return items.sorted { $0.dateAdded > $1.dateAdded }
        case .title:
            return items.sorted { $0.title < $1.title }
        case .favorite:
            return items.sorted { first, second in
                if first.isFavorite != second.isFavorite {
                    return first.isFavorite
                }
                return first.dateAdded > second.dateAdded
            }
        }
    }

    /// Fetch "completed" items in a category
    func fetchCompleted(in category: Category) -> [StashItem] {
        let allInCategory = self.fetchByCategory(category)

        return allInCategory.filter { item in
            switch item.category {
            case .recipe:
                item.flags["hasBeenCooked"] == true
            case .book:
                item.flags["hasRead"] == true
            case .movie:
                item.flags["hasWatched"] == true
            case .music:
                item.flags["hasListened"] == true
            case .clothes, .home:
                item.flags["hasBought"] == true
            case .article:
                item.flags["hasRead"] == true
            case .podcast:
                item.flags["hasListened"] == true
            case .trip:
                item.flags["hasVisited"] == true
            case .backpack:
                item.flags["hasReviewed"] == true
            }
        }
    }
}
