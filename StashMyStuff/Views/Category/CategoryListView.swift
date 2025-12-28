//
//  CategoryListView.swift
//  StashMyStuff
//
//  Displays items in a category with filtering, sorting, and swipe actions.
//  Supports list and grid layouts with empty state handling.
//

import SwiftData
import SwiftUI

struct CategoryListView: View {
    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext
    @Environment(AppCoordinator.self)
    private var coordinator

    // MARK: - Properties

    let category: Category

    // MARK: - State

    @State
    private var viewModel: CategoryListViewModel?
    @State
    private var showSortOptions = false

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
        .navigationTitle(self.category.rawValue)
        .toolbar {
            self.toolbarContent
        }
        .searchable(
            text: Binding(
                get: { self.viewModel?.searchText ?? "" },
                set: { self.viewModel?.searchText = $0 }
            ),
            prompt: "Search \(self.category.rawValue.lowercased())..."
        )
        .onAppear {
            if self.viewModel == nil {
                let repository = StashRepository(modelContext: self.modelContext)
                self.viewModel = CategoryListViewModel(category: self.category, repository: repository)
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
    private func listContent(viewModel: CategoryListViewModel) -> some View {
        VStack(spacing: 0) {
            // Filter tabs
            self.filterTabs(viewModel: viewModel)

            // Item list
            List {
                ForEach(viewModel.filteredItems) { item in
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

                        if let flagKey = viewModel.primaryFlagKey {
                            Button {
                                viewModel.toggleFlag(flagKey, for: item)
                            } label: {
                                let isActive = item.flags[flagKey] ?? false
                                Label(
                                    isActive ? "Undo" : "Done",
                                    systemImage: isActive ? "arrow.uturn.backward" : "checkmark"
                                )
                            }
                            .tint(.green)
                        }
                    }
                }
                .onDelete { indexSet in
                    viewModel.deleteItems(at: indexSet)
                }
            }
            .listStyle(.plain)
        }
    }

    // MARK: - Filter Tabs

    @ViewBuilder
    private func filterTabs(viewModel: CategoryListViewModel) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(ItemFilter.allCases) { filter in
                    FilterTabButton(
                        title: filter.rawValue,
                        isSelected: viewModel.filter == filter,
                        color: self.category.color
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.filter = filter
                        }
                        HapticService.shared.selectionChanged()
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Empty State

    @ViewBuilder
    private func emptyStateView(viewModel: CategoryListViewModel) -> some View {
        EmptyStateView(
            category: self.category,
            message: viewModel.emptyMessage,
            actionTitle: "Add to \(self.category.rawValue)"
        ) {
            self.coordinator.showAddItem(for: self.category)
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                self.coordinator.showAddItem(for: self.category)
            } label: {
                Image(systemName: "plus")
            }
        }

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
}

// MARK: - Filter Tab Button

struct FilterTabButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            Text(self.title)
                .font(DesignTokens.Typography.subheadline)
                .fontWeight(self.isSelected ? .semibold : .regular)
                .foregroundStyle(self.isSelected ? .white : .primary)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background {
                    Capsule()
                        .fill(self.isSelected ? self.color : Color(.systemGray5))
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("CategoryListView - Recipes") {
    NavigationStack {
        CategoryListView(category: .recipe)
    }
    .modelContainer(for: [StashItem.self, Tag.self], inMemory: true)
    .environment(AppCoordinator())
}

#Preview("CategoryListView with Data") {
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
        StashItem(title: "Homemade Pizza", category: .recipe, sourceURL: URL(string: "https://allrecipes.com")),
        StashItem(title: "Banana Bread", category: .recipe, sourceURL: nil)
    ]

    for item in items {
        context.insert(item)
    }

    items[0].flags["hasBeenCooked"] = true
    items[0].isFavorite = true

    return NavigationStack {
        CategoryListView(category: .recipe)
    }
    .modelContainer(container)
    .environment(AppCoordinator())
}
