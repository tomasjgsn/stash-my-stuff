//
//  HomeView.swift
//  StashMyStuff
//
//  The main home screen displaying category grid and smart views.
//  Uses a grid layout for categories and a horizontal scroll for smart views.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext
    @Environment(AppCoordinator.self)
    private var coordinator

    // MARK: - State

    @State
    private var viewModel: HomeViewModel?
    @State
    private var searchText = ""

    // MARK: - Grid Layout

    private let categoryColumns = [
        GridItem(.flexible(), spacing: DesignTokens.Spacing.md),
        GridItem(.flexible(), spacing: DesignTokens.Spacing.md)
    ]

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Smart Views Section
                if let vm = self.viewModel, !vm.activeSmartViews.isEmpty {
                    self.smartViewsSection(viewModel: vm)
                }

                // Categories Section
                self.categoriesSection
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.top, DesignTokens.Spacing.md)
        }
        .navigationTitle("Stash")
        .searchable(text: self.$searchText, prompt: "Search items...")
        .onChange(of: self.searchText) { _, newValue in
            self.viewModel?.searchText = newValue
            self.viewModel?.performSearch()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    self.coordinator.showAddItem()
                } label: {
                    Image(systemName: "plus")
                        .font(.title3)
                }
            }
        }
        .overlay {
            if let vm = self.viewModel, vm.isSearching {
                self.searchResultsOverlay(viewModel: vm)
            }
        }
        .onAppear {
            if self.viewModel == nil {
                let repository = StashRepository(modelContext: self.modelContext)
                self.viewModel = HomeViewModel(repository: repository)
            } else {
                self.viewModel?.refreshData()
            }
        }
        .refreshable {
            self.viewModel?.refreshData()
        }
    }

    // MARK: - Smart Views Section

    @ViewBuilder
    private func smartViewsSection(viewModel: HomeViewModel) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Smart Views")
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(viewModel.activeSmartViews) { smartView in
                        SmartViewCard(
                            smartView: smartView,
                            count: viewModel.count(for: smartView)
                        ) {
                            self.coordinator.navigateToSmartView(smartView)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Categories")
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: self.categoryColumns, spacing: DesignTokens.Spacing.md) {
                ForEach(Category.allCases, id: \.self) { category in
                    Button {
                        self.coordinator.navigateToCategory(category)
                    } label: {
                        CategoryCard(
                            category,
                            itemCount: self.viewModel?.count(for: category) ?? 0,
                            style: .grid
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Search Results Overlay

    @ViewBuilder
    private func searchResultsOverlay(viewModel: HomeViewModel) -> some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            if viewModel.searchResults.isEmpty {
                ContentUnavailableView.search(text: self.searchText)
            } else {
                List(viewModel.searchResults) { item in
                    Button {
                        self.coordinator.navigateToItem(item)
                    } label: {
                        StashItemRow(item: item, style: .standard)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
    }
}

// MARK: - Smart View Card

struct SmartViewCard: View {
    let smartView: SmartView
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack {
                    Image(systemName: self.smartView.icon)
                        .font(.title2)
                        .foregroundStyle(self.smartView.color)

                    Spacer()

                    Text("\(self.count)")
                        .font(DesignTokens.Typography.title)
                        .fontWeight(.bold)
                }

                Text(self.smartView.rawValue)
                    .font(DesignTokens.Typography.subheadline)
                    .foregroundStyle(.primary)
            }
            .padding(DesignTokens.Spacing.md)
            .frame(width: 140)
            .glassCard()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("HomeView") {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: [StashItem.self, Tag.self], inMemory: true)
    .environment(AppCoordinator())
}

#Preview("HomeView with Data") {
    let container = try! ModelContainer(
        for: StashItem.self, Tag.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // Add sample data
    let context = container.mainContext

    let recipes = [
        StashItem(
            title: "Chocolate Chip Cookies",
            category: .recipe,
            sourceURL: URL(string: "https://cooking.nytimes.com/recipe/123")
        ),
        StashItem(
            title: "Homemade Pizza",
            category: .recipe,
            sourceURL: URL(string: "https://allrecipes.com/recipe/456")
        ),
        StashItem(title: "Banana Bread", category: .recipe, sourceURL: nil)
    ]

    let books = [
        StashItem(title: "The Great Gatsby", category: .book, sourceURL: URL(string: "https://goodreads.com/book/123")),
        StashItem(title: "1984", category: .book, sourceURL: nil)
    ]

    for item in recipes + books {
        context.insert(item)
    }

    recipes[0].isFavorite = true
    books[0].flags["hasBought"] = true

    return NavigationStack {
        HomeView()
    }
    .modelContainer(container)
    .environment(AppCoordinator())
}
