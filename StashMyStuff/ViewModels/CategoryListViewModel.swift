//
//  CategoryListViewModel.swift
//  StashMyStuff
//
//  ViewModel for the Category List screen. Handles filtering, sorting,
//  and item management for a specific category.
//

import Foundation
import Observation
import SwiftData

/// Filter options for category lists
enum ItemFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case incomplete = "To Do"
    case complete = "Done"
    case favorites = "Favorites"

    var id: String { rawValue }
}

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
        var result = self.items

        // Apply filter
        switch self.filter {
        case .all:
            break
        case .incomplete:
            result = result.filter { !self.isItemComplete($0) }
        case .complete:
            result = result.filter { self.isItemComplete($0) }
        case .favorites:
            result = result.filter(\.isFavorite)
        }

        // Apply search
        if !self.searchText.isEmpty {
            let lowercased = self.searchText.lowercased()
            result = result.filter { item in
                item.title.lowercased().contains(lowercased) ||
                    item.notes.lowercased().contains(lowercased)
            }
        }

        return result
    }

    var categoryConfig: CategoryConfig? {
        CategoryConfig.config(for: self.category)
    }

    var isEmpty: Bool {
        self.items.isEmpty
    }

    var emptyMessage: String {
        switch self.category {
        case .recipe: "No recipes saved yet.\nAdd your first recipe to get started!"
        case .book: "Your reading list is empty.\nAdd books you want to read or have read."
        case .movie: "No movies or shows saved.\nStart tracking what you want to watch!"
        case .music: "Your music collection is empty.\nSave albums and tracks you love."
        case .clothes: "No clothing items saved.\nAdd items you're eyeing or own."
        case .home: "No home items saved.\nSave furniture and decor inspiration."
        case .article: "No articles saved.\nSave interesting reads for later."
        case .podcast: "No podcasts saved.\nAdd episodes you want to listen to."
        case .trip: "No trips planned.\nSave destinations you want to visit."
        case .backpack: "Your backpack is empty.\nAdd miscellaneous items here."
        }
    }

    // MARK: - Initialization

    init(category: Category, repository: StashRepository) {
        self.category = category
        self.repository = repository
        self.loadItems()
    }

    // MARK: - Data Loading

    func loadItems() {
        self.items = self.repository.fetchByCategory(self.category, sortedBy: self.sortOption)
    }

    func refresh() {
        self.loadItems()
    }

    // MARK: - Item Operations

    func toggleFavorite(_ item: StashItem) {
        item.isFavorite.toggle()
        self.repository.save(item)
        HapticService.shared.favoriteToggled(isFavorite: item.isFavorite)
    }

    func toggleFlag(_ flagKey: String, for item: StashItem) {
        let currentValue = item.flags[flagKey] ?? false
        item.flags[flagKey] = !currentValue
        self.repository.save(item)
        HapticService.shared.flagToggled(isNowActive: !currentValue)
    }

    func deleteItem(_ item: StashItem) {
        self.repository.delete(item)
        self.items.removeAll { $0.id == item.id }
        HapticService.shared.itemDeleted()
    }

    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = self.filteredItems[index]
            self.repository.delete(item)
        }
        self.loadItems()
        HapticService.shared.itemDeleted()
    }

    // MARK: - Helpers

    private func isItemComplete(_ item: StashItem) -> Bool {
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

    /// Get the primary flag key for quick toggle in list
    var primaryFlagKey: String? {
        self.categoryConfig?.flags.first?.key
    }
}
