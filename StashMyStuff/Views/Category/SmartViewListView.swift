//
//  SmartViewListView.swift
//  StashMyStuff
//
//  Displays items for a smart view (Favorites, Uncooked Recipes, etc.)
//  with swipe actions and empty state handling.
//

import SwiftData
import SwiftUI

struct SmartViewListView: View {
    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext
    @Environment(AppCoordinator.self)
    private var coordinator

    // MARK: - Properties

    let smartView: SmartView

    // MARK: - State

    @State
    private var viewModel: SmartViewListViewModel?

    // MARK: - Body

    var body: some View {
        Group {
            if let vm = self.viewModel {
                if vm.isEmpty {
                    self.emptyStateView(viewModel: vm)
                } else {
                    self.listContent(viewModel: vm)
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle(self.smartView.rawValue)
        .toolbar {
            ToolbarItem(placement: .secondaryAction) {
                Menu {
                    Picker("Sort By", selection: Binding(
                        get: { self.viewModel?.sortOption ?? .dateAdded },
                        set: { option in
                            self.viewModel?.sortOption = option
                            self.viewModel?.loadItems()
                        }
                    )) {
                        Label("Date Added", systemImage: "calendar")
                            .tag(SortOption.dateAdded)
                        Label("Title", systemImage: "textformat")
                            .tag(SortOption.title)
                        Label("Favorites First", systemImage: "heart")
                            .tag(SortOption.favorite)
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
        .onAppear {
            if self.viewModel == nil {
                let repository = StashRepository(modelContext: self.modelContext)
                self.viewModel = SmartViewListViewModel(smartView: self.smartView, repository: repository)
            } else {
                self.viewModel?.refresh()
            }
        }
        .refreshable {
            self.viewModel?.refresh()
        }
    }

    // MARK: - List Content

    @ViewBuilder
    private func listContent(viewModel: SmartViewListViewModel) -> some View {
        List(viewModel.items) { item in
            Button {
                self.coordinator.navigateToItem(item)
            } label: {
                StashItemRow(item: item, style: .standard) {
                    viewModel.toggleFavorite(item)
                }
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    viewModel.deleteItem(item)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
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
            }
        }
        .listStyle(.plain)
    }

    // MARK: - Empty State

    @ViewBuilder
    private func emptyStateView(viewModel: SmartViewListViewModel) -> some View {
        ContentUnavailableView {
            Label(viewModel.title, systemImage: viewModel.icon)
        } description: {
            Text(viewModel.emptyMessage)
        }
    }
}

// MARK: - Previews

#Preview("SmartViewListView - Favorites") {
    NavigationStack {
        SmartViewListView(smartView: .favorites)
    }
    .modelContainer(for: [StashItem.self, Tag.self], inMemory: true)
    .environment(AppCoordinator())
}

#Preview("SmartViewListView - Uncooked Recipes") {
    let container = try! ModelContainer(
        for: StashItem.self, Tag.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext

    let items = [
        StashItem(
            title: "Chocolate Chip Cookies",
            category: .recipe,
            sourceURL: URL(string: "https://cooking.nytimes.com")
        ),
        StashItem(title: "Homemade Pizza", category: .recipe, sourceURL: URL(string: "https://allrecipes.com"))
    ]

    for item in items {
        context.insert(item)
    }

    return NavigationStack {
        SmartViewListView(smartView: .uncookedRecipes)
    }
    .modelContainer(container)
    .environment(AppCoordinator())
}
