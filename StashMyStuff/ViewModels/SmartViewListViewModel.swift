//
//  SmartViewListViewModel.swift
//  StashMyStuff
//
//  ViewModel for Smart View lists (Favorites, Uncooked Recipes, etc.)
//  Handles loading and managing items for predefined filtered views.
//

import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class SmartViewListViewModel {
    // MARK: - Dependencies

    private let repository: StashRepository
    let smartView: SmartView

    // MARK: - State

    private(set) var items: [StashItem] = []
    var sortOption: SortOption = .dateAdded

    // MARK: - Computed Properties

    var title: String {
        self.smartView.rawValue
    }

    var icon: String {
        self.smartView.icon
    }

    var color: Color {
        self.smartView.color
    }

    var isEmpty: Bool {
        self.items.isEmpty
    }

    var emptyMessage: String {
        switch self.smartView {
        case .uncookedRecipes:
            "No uncooked recipes.\nAll your recipes have been cooked!"
        case .toRead:
            "Nothing to read.\nBuy some books or mark them as unread."
        case .bandcampQueue:
            "Bandcamp queue is empty.\nMark music you want to purchase."
        case .unwatched:
            "All caught up!\nNo unwatched movies or shows."
        case .favorites:
            "No favorites yet.\nTap the heart on items you love."
        case .recentlyAdded:
            "No recent items.\nAdd something new to see it here."
        }
    }

    // MARK: - Initialization

    init(smartView: SmartView, repository: StashRepository) {
        self.smartView = smartView
        self.repository = repository
        self.loadItems()
    }

    // MARK: - Data Loading

    func loadItems() {
        switch self.smartView {
        case .uncookedRecipes:
            self.items = self.repository.fetchUncookedRecipes()
        case .toRead:
            self.items = self.repository.fetchToRead()
        case .bandcampQueue:
            self.items = self.repository.fetchBandcampQueue()
        case .unwatched:
            self.items = self.repository.fetchUnwatchedMovies()
        case .favorites:
            self.items = self.repository.fetchFavorites()
        case .recentlyAdded:
            self.items = self.repository.fetchRecent(days: 7)
        }

        self.applySorting()
    }

    func refresh() {
        self.loadItems()
    }

    // MARK: - Sorting

    private func applySorting() {
        switch self.sortOption {
        case .dateAdded:
            self.items.sort { $0.dateAdded > $1.dateAdded }
        case .title:
            self.items.sort { $0.title < $1.title }
        case .favorite:
            self.items.sort { first, second in
                if first.isFavorite != second.isFavorite {
                    return first.isFavorite
                }
                return first.dateAdded > second.dateAdded
            }
        }
    }

    // MARK: - Item Operations

    func toggleFavorite(_ item: StashItem) {
        item.isFavorite.toggle()
        self.repository.save(item)
        HapticService.shared.favoriteToggled(isFavorite: item.isFavorite)

        // Reload if this is the favorites view
        if self.smartView == .favorites {
            self.loadItems()
        }
    }

    func deleteItem(_ item: StashItem) {
        self.repository.delete(item)
        self.items.removeAll { $0.id == item.id }
        HapticService.shared.itemDeleted()
    }
}

import SwiftUI
