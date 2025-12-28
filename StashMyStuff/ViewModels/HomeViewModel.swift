//
//  HomeViewModel.swift
//  StashMyStuff
//
//  ViewModel for the Home screen. Manages category counts, smart view data,
//  and search state using @Observable for SwiftUI integration.
//

import Foundation
import Observation
import SwiftData

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
        self.refreshData()
    }

    // MARK: - Data Loading

    func refreshData() {
        self.loadCategoryCounts()
        self.loadSmartViewCounts()
    }

    private func loadCategoryCounts() {
        for category in Category.allCases {
            let items = self.repository.fetchByCategory(category)
            self.categoryCounts[category] = items.count
        }
    }

    private func loadSmartViewCounts() {
        self.smartViewCounts[.uncookedRecipes] = self.repository.fetchUncookedRecipes().count
        self.smartViewCounts[.toRead] = self.repository.fetchToRead().count
        self.smartViewCounts[.bandcampQueue] = self.repository.fetchBandcampQueue().count
        self.smartViewCounts[.unwatched] = self.repository.fetchUnwatchedMovies().count
        self.smartViewCounts[.favorites] = self.repository.fetchFavorites().count
        self.smartViewCounts[.recentlyAdded] = self.repository.fetchRecent(days: 7).count
    }

    // MARK: - Search

    func performSearch() {
        guard !self.searchText.isEmpty else {
            self.searchResults = []
            self.isSearching = false
            return
        }

        self.isSearching = true
        self.searchResults = self.repository.search(query: self.searchText)
    }

    func clearSearch() {
        self.searchText = ""
        self.searchResults = []
        self.isSearching = false
    }

    // MARK: - Computed Properties

    var totalItemCount: Int {
        self.categoryCounts.values.reduce(0, +)
    }

    var activeSmartViews: [SmartView] {
        SmartView.allCases.filter { view in
            (self.smartViewCounts[view] ?? 0) > 0
        }
    }

    func count(for category: Category) -> Int {
        self.categoryCounts[category] ?? 0
    }

    func count(for smartView: SmartView) -> Int {
        self.smartViewCounts[smartView] ?? 0
    }
}
