//
//  ItemDetailView.swift
//  StashMyStuff
//
//  Displays full item details with hero image, flags, notes, and tags.
//  Supports editing mode and delete confirmation.
//

import SwiftData
import SwiftUI

struct ItemDetailView: View {
    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.dismiss)
    private var dismiss
    @Environment(AppCoordinator.self)
    private var coordinator

    // MARK: - Properties

    let item: StashItem

    // MARK: - State

    @State
    private var viewModel: ItemDetailViewModel?

    // MARK: - Body

    var body: some View {
        Group {
            if let vm = self.viewModel {
                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.lg) {
                        // Hero Image
                        self.heroSection(viewModel: vm)

                        // Content
                        VStack(spacing: DesignTokens.Spacing.lg) {
                            // Metadata
                            self.metadataSection(viewModel: vm)

                            // Flags
                            self.flagsSection(viewModel: vm)

                            // Notes
                            self.notesSection(viewModel: vm)

                            // Tags
                            self.tagsSection(viewModel: vm)

                            // Actions
                            self.actionsSection(viewModel: vm)
                        }
                        .padding(.horizontal, DesignTokens.Spacing.md)
                    }
                }
                .navigationTitle(vm.item.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    self.toolbarContent(viewModel: vm)
                }
                .confirmationDialog(
                    "Delete Item",
                    isPresented: Binding(
                        get: { vm.showDeleteConfirmation },
                        set: { vm.showDeleteConfirmation = $0 }
                    ),
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        vm.delete()
                    }
                } message: {
                    Text("Are you sure you want to delete \"\(vm.item.title)\"? This cannot be undone.")
                }
                .onChange(of: vm.isDeleted) { _, isDeleted in
                    if isDeleted {
                        self.dismiss()
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            if self.viewModel == nil {
                let repository = StashRepository(modelContext: self.modelContext)
                self.viewModel = ItemDetailViewModel(item: self.item, repository: repository)
            }
        }
    }

    // MARK: - Hero Section

    @ViewBuilder
    private func heroSection(viewModel: ItemDetailViewModel) -> some View {
        ZStack(alignment: .topTrailing) {
            ItemThumbnail(
                url: viewModel.item.imageURL,
                category: viewModel.item.category,
                size: .hero
            )
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipped()

            // Favorite button
            Button {
                viewModel.toggleFavorite()
            } label: {
                Image(systemName: viewModel.item.isFavorite ? "heart.fill" : "heart")
                    .font(.title2)
                    .foregroundStyle(viewModel.item.isFavorite ? .red : .white)
                    .padding(DesignTokens.Spacing.sm)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                    }
            }
            .padding(DesignTokens.Spacing.md)
        }
    }

    // MARK: - Metadata Section

    @ViewBuilder
    private func metadataSection(viewModel: ItemDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            // Category badge
            Text(viewModel.item.category.rawValue)
                .categoryBadge(viewModel.item.category)

            // Title
            Text(viewModel.item.title)
                .font(DesignTokens.Typography.largeTitle)
                .fontWeight(.bold)

            // Source
            if let domain = viewModel.sourceDomain {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    SourceIcon(url: viewModel.item.sourceURL!, size: 16)
                    Text(domain)
                        .font(DesignTokens.Typography.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Date added
            HStack(spacing: DesignTokens.Spacing.xs) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("Added \(viewModel.formattedDate)")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Flags Section

    @ViewBuilder
    private func flagsSection(viewModel: ItemDetailViewModel) -> some View {
        if let config = viewModel.categoryConfig, !config.flags.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Status")
                    .font(DesignTokens.Typography.headline)

                FlowLayout(spacing: DesignTokens.Spacing.sm) {
                    ForEach(config.flags, id: \.key) { flag in
                        switch flag.type {
                        case .toggle:
                            FlagButton(
                                flag: flag,
                                isActive: Binding(
                                    get: { viewModel.item.flags[flag.key] ?? false },
                                    set: { _ in viewModel.toggleFlag(flag.key) }
                                )
                            )
                        case .rating:
                            RatingView(
                                rating: Binding(
                                    get: { viewModel.getRating(flag.key) },
                                    set: { viewModel.setRating(flag.key, value: $0) }
                                ),
                                label: flag.label
                            )
                        }
                    }
                }
            }
            .padding(DesignTokens.Spacing.md)
            .glassCard()
        }
    }

    // MARK: - Notes Section

    @ViewBuilder
    private func notesSection(viewModel: ItemDetailViewModel) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Notes")
                .font(DesignTokens.Typography.headline)

            if viewModel.item.notes.isEmpty {
                Text("No notes yet")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                Text(viewModel.item.notes)
                    .font(DesignTokens.Typography.body)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.md)
        .glassCard()
    }

    // MARK: - Tags Section

    @ViewBuilder
    private func tagsSection(viewModel: ItemDetailViewModel) -> some View {
        if !viewModel.tagNames.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Tags")
                    .font(DesignTokens.Typography.headline)

                TagDisplay(
                    viewModel.tagNames,
                    color: viewModel.item.category.color
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Spacing.md)
            .glassCard()
        }
    }

    // MARK: - Actions Section

    @ViewBuilder
    private func actionsSection(viewModel: ItemDetailViewModel) -> some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            // Open link button
            if viewModel.canOpenLink {
                Button {
                    viewModel.openLink()
                } label: {
                    Label("Open Original Link", systemImage: "safari")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle(color: viewModel.item.category.color))
            }

            // Delete button
            Button(role: .destructive) {
                viewModel.confirmDelete()
            } label: {
                Label("Delete Item", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DestructiveButtonStyle())
        }
        .padding(.top, DesignTokens.Spacing.lg)
        .padding(.bottom, DesignTokens.Spacing.xl)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private func toolbarContent(viewModel: ItemDetailViewModel) -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Edit") {
                self.coordinator.showEditItem(viewModel.item)
            }
        }
    }
}

// MARK: - Rating View

struct RatingView: View {
    @Binding
    var rating: Int
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(self.label)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: DesignTokens.Spacing.xxs) {
                ForEach(1 ... 5, id: \.self) { star in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            self.rating = star
                        }
                        HapticService.shared.selectionChanged()
                    } label: {
                        Image(systemName: star <= self.rating ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundStyle(star <= self.rating ? .yellow : .secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("ItemDetailView") {
    let container = try! ModelContainer(
        for: StashItem.self, Tag.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext
    let item = StashItem(
        title: "Chocolate Chip Cookies",
        category: .recipe,
        sourceURL: URL(string: "https://cooking.nytimes.com/recipes/chocolate-chip-cookies")
    )
    item.notes = "This is grandma's secret recipe. Don't forget to add extra chocolate chips!"
    item.isFavorite = true
    item.flags["hasBeenCooked"] = true
    context.insert(item)

    return NavigationStack {
        ItemDetailView(item: item)
    }
    .modelContainer(container)
    .environment(AppCoordinator())
}

#Preview("ItemDetailView - Book") {
    let container = try! ModelContainer(
        for: StashItem.self, Tag.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext
    let item = StashItem(
        title: "The Great Gatsby",
        category: .book,
        sourceURL: URL(string: "https://goodreads.com/book/the-great-gatsby")
    )
    item.flags["hasBought"] = true
    item.metadata["rating"] = "4"
    context.insert(item)

    return NavigationStack {
        ItemDetailView(item: item)
    }
    .modelContainer(container)
    .environment(AppCoordinator())
}

#Preview("RatingView") {
    struct PreviewWrapper: View {
        @State
        private var rating = 3

        var body: some View {
            RatingView(rating: self.$rating, label: "Rating")
                .padding()
        }
    }

    return PreviewWrapper()
}
