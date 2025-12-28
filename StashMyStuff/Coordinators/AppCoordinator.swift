//
//  AppCoordinator.swift
//  StashMyStuff
//
//  Central navigation coordinator using NavigationStack with typed destinations.
//  Manages app-wide navigation state and provides navigation methods.
//

import Observation
import SwiftData
import SwiftUI

// MARK: - Navigation Destinations

/// Type-safe navigation destinations for the app
enum AppDestination: Hashable {
    case category(Category)
    case itemDetail(StashItem)
    case smartView(SmartView)
    case settings
    case search
}

/// Smart view types for filtered lists
enum SmartView: String, Hashable, CaseIterable, Identifiable {
    case uncookedRecipes = "Uncooked Recipes"
    case toRead = "To Read"
    case bandcampQueue = "Bandcamp Queue"
    case unwatched = "Unwatched"
    case favorites = "Favorites"
    case recentlyAdded = "Recently Added"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .uncookedRecipes: "flame"
        case .toRead: "book"
        case .bandcampQueue: "music.note"
        case .unwatched: "play.circle"
        case .favorites: "heart.fill"
        case .recentlyAdded: "clock"
        }
    }

    var color: Color {
        switch self {
        case .uncookedRecipes: .orange
        case .toRead: .indigo
        case .bandcampQueue: .pink
        case .unwatched: .purple
        case .favorites: .red
        case .recentlyAdded: .blue
        }
    }
}

// MARK: - App Coordinator

@Observable
@MainActor
final class AppCoordinator {
    // MARK: - Navigation State

    var navigationPath = NavigationPath()
    var showingAddSheet = false
    var showingSearchSheet = false
    var selectedCategory: Category?

    // For edit mode
    var editingItem: StashItem?

    // MARK: - Navigation Methods

    func navigate(to destination: AppDestination) {
        self.navigationPath.append(destination)
    }

    func navigateToCategory(_ category: Category) {
        self.navigate(to: .category(category))
    }

    func navigateToItem(_ item: StashItem) {
        self.navigate(to: .itemDetail(item))
    }

    func navigateToSmartView(_ smartView: SmartView) {
        self.navigate(to: .smartView(smartView))
    }

    func pop() {
        guard !self.navigationPath.isEmpty else { return }
        self.navigationPath.removeLast()
    }

    func popToRoot() {
        self.navigationPath = NavigationPath()
    }

    // MARK: - Sheet Management

    func showAddItem(for category: Category? = nil) {
        self.selectedCategory = category
        self.editingItem = nil
        self.showingAddSheet = true
    }

    func showEditItem(_ item: StashItem) {
        self.selectedCategory = item.category
        self.editingItem = item
        self.showingAddSheet = true
    }

    func dismissSheet() {
        self.showingAddSheet = false
        self.showingSearchSheet = false
        self.editingItem = nil
        self.selectedCategory = nil
    }

    func showSearch() {
        self.showingSearchSheet = true
    }
}

// MARK: - Navigation Path Extension

extension NavigationPath {
    /// Helper to check if we're at root
    var isAtRoot: Bool {
        self.isEmpty
    }
}
