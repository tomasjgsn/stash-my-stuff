//
//  ContentView.swift
//  StashMyStuff
//
//  Root view that sets up navigation and coordinates between screens.
//  Uses NavigationStack with typed destinations for type-safe navigation.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext

    // MARK: - State

    @State
    private var coordinator = AppCoordinator()

    // MARK: - Body

    var body: some View {
        NavigationStack(path: self.$coordinator.navigationPath) {
            HomeView()
                .navigationDestination(for: AppDestination.self) { destination in
                    self.destinationView(for: destination)
                }
        }
        .environment(self.coordinator)
        .sheet(isPresented: self.$coordinator.showingAddSheet) {
            AddEditItemSheet(
                existingItem: self.coordinator.editingItem,
                initialCategory: self.coordinator.selectedCategory
            )
            .environment(self.coordinator)
        }
    }

    // MARK: - Navigation Destinations

    @ViewBuilder
    private func destinationView(for destination: AppDestination) -> some View {
        switch destination {
        case let .category(category):
            CategoryListView(category: category)

        case let .itemDetail(item):
            ItemDetailView(item: item)

        case let .smartView(smartView):
            SmartViewListView(smartView: smartView)

        case .settings:
            SettingsView()

        case .search:
            SearchView()
        }
    }
}

// MARK: - Settings View (Placeholder)

struct SettingsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    Text("Appearance settings coming soon")
                } label: {
                    Label("Appearance", systemImage: "paintbrush")
                }

                NavigationLink {
                    Text("Notification settings coming soon")
                } label: {
                    Label("Notifications", systemImage: "bell")
                }
            }

            Section {
                NavigationLink {
                    Text("About")
                } label: {
                    Label("About", systemImage: "info.circle")
                }
            }
        }
        .navigationTitle("Settings")
    }
}

// MARK: - Search View (Placeholder)

struct SearchView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Environment(AppCoordinator.self)
    private var coordinator

    @State
    private var searchText = ""
    @State
    private var results: [StashItem] = []

    var body: some View {
        List(self.results) { item in
            Button {
                self.coordinator.navigateToItem(item)
            } label: {
                StashItemRow(item: item, style: .standard)
            }
            .buttonStyle(.plain)
        }
        .searchable(text: self.$searchText, prompt: "Search all items...")
        .onChange(of: self.searchText) { _, newValue in
            self.performSearch(query: newValue)
        }
        .navigationTitle("Search")
        .overlay {
            if self.searchText.isEmpty {
                ContentUnavailableView(
                    "Search Items",
                    systemImage: "magnifyingglass",
                    description: Text("Search by title or notes")
                )
            } else if self.results.isEmpty {
                ContentUnavailableView.search(text: self.searchText)
            }
        }
    }

    private func performSearch(query: String) {
        guard !query.isEmpty else {
            self.results = []
            return
        }

        let repository = StashRepository(modelContext: self.modelContext)
        self.results = repository.search(query: query)
    }
}

// MARK: - Preview

#Preview("ContentView") {
    ContentView()
        .modelContainer(for: [StashItem.self, Tag.self], inMemory: true)
}

#Preview("ContentView with Data") {
    let container = try! ModelContainer(
        for: StashItem.self, Tag.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext

    // Add sample data
    let recipes = [
        StashItem(
            title: "Chocolate Chip Cookies",
            category: .recipe,
            sourceURL: URL(string: "https://cooking.nytimes.com")
        ),
        StashItem(title: "Homemade Pizza", category: .recipe, sourceURL: URL(string: "https://allrecipes.com")),
        StashItem(title: "Banana Bread", category: .recipe, sourceURL: nil)
    ]

    let books = [
        StashItem(title: "The Great Gatsby", category: .book, sourceURL: URL(string: "https://goodreads.com")),
        StashItem(title: "1984", category: .book, sourceURL: nil)
    ]

    let movies = [
        StashItem(title: "Inception", category: .movie, sourceURL: URL(string: "https://imdb.com"))
    ]

    for item in recipes + books + movies {
        context.insert(item)
    }

    recipes[0].isFavorite = true
    books[0].flags["hasBought"] = true

    return ContentView()
        .modelContainer(container)
}
