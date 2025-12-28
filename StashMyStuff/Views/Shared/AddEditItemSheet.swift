//
//  AddEditItemSheet.swift
//  StashMyStuff
//
//  A form sheet for adding new items or editing existing ones.
//  Includes category selection, URL input, tags, notes, and flags.
//

import SwiftData
import SwiftUI

struct AddEditItemSheet: View {
    // MARK: - Environment

    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.dismiss)
    private var dismiss
    @Environment(AppCoordinator.self)
    private var coordinator

    // MARK: - Properties

    let existingItem: StashItem?
    let initialCategory: Category?

    // MARK: - State

    @State
    private var viewModel: AddEditItemViewModel?

    // MARK: - Initialization

    init(existingItem: StashItem? = nil, initialCategory: Category? = nil) {
        self.existingItem = existingItem
        self.initialCategory = initialCategory
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if let vm = self.viewModel {
                    self.formContent(viewModel: vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle(self.viewModel?.navigationTitle ?? "Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(self.viewModel?.saveButtonTitle ?? "Save") {
                        self.viewModel?.save()
                    }
                    .disabled(!(self.viewModel?.isValid ?? false))
                    .fontWeight(.semibold)
                }
            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { self.viewModel?.errorMessage != nil },
                    set: { if !$0 { self.viewModel?.clearError() } }
                )
            ) {
                Button("OK") {
                    self.viewModel?.clearError()
                }
            } message: {
                Text(self.viewModel?.errorMessage ?? "")
            }
            .onChange(of: self.viewModel?.didSave ?? false) { _, didSave in
                if didSave {
                    self.dismiss()
                }
            }
        }
        .onAppear {
            if self.viewModel == nil {
                let repository = StashRepository(modelContext: self.modelContext)
                self.viewModel = AddEditItemViewModel(
                    repository: repository,
                    existingItem: self.existingItem,
                    initialCategory: self.initialCategory
                )
            }
        }
    }

    // MARK: - Form Content

    @ViewBuilder
    private func formContent(viewModel: AddEditItemViewModel) -> some View {
        Form {
            // Category Section
            self.categorySection(viewModel: viewModel)

            // Details Section
            self.detailsSection(viewModel: viewModel)

            // Tags Section
            self.tagsSection(viewModel: viewModel)

            // Flags Section
            self.flagsSection(viewModel: viewModel)

            // Notes Section
            self.notesSection(viewModel: viewModel)

            // Options Section
            self.optionsSection(viewModel: viewModel)
        }
    }

    // MARK: - Category Section

    @ViewBuilder
    private func categorySection(viewModel: AddEditItemViewModel) -> some View {
        Section {
            // Category picker with icons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(Category.allCases, id: \.self) { category in
                        CategoryPickerItem(
                            category: category,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.selectedCategory = category
                            }
                            HapticService.shared.categorySelected()
                        }
                    }
                }
                .padding(.vertical, DesignTokens.Spacing.xs)
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        } header: {
            Text("Category")
        }
    }

    // MARK: - Details Section

    @ViewBuilder
    private func detailsSection(viewModel: AddEditItemViewModel) -> some View {
        Section {
            // Title
            TextField("Title", text: Binding(
                get: { viewModel.title },
                set: { viewModel.title = $0 }
            ))
            .textContentType(.none)

            // URL
            TextField("URL (optional)", text: Binding(
                get: { viewModel.sourceURL },
                set: { viewModel.sourceURL = $0 }
            ))
            .textContentType(.URL)
            .keyboardType(.URL)
            .autocapitalization(.none)
            .autocorrectionDisabled()

            // URL validation indicator
            if !viewModel.sourceURL.isEmpty {
                HStack {
                    Image(systemName: viewModel.isURLValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(viewModel.isURLValid ? .green : .red)
                    Text(viewModel.isURLValid ? "Valid URL" : "Invalid URL format")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Details")
        }
    }

    // MARK: - Tags Section

    @ViewBuilder
    private func tagsSection(viewModel: AddEditItemViewModel) -> some View {
        Section {
            TagInput(
                tags: Binding(
                    get: { viewModel.tags },
                    set: { viewModel.tags = $0 }
                ),
                suggestions: self.commonTagSuggestions,
                placeholder: "Add tags...",
                maxTags: 10
            )
        } header: {
            Text("Tags")
        }
    }

    // MARK: - Flags Section

    @ViewBuilder
    private func flagsSection(viewModel: AddEditItemViewModel) -> some View {
        if !viewModel.availableFlags.isEmpty {
            Section {
                ForEach(viewModel.availableFlags, id: \.key) { flag in
                    switch flag.type {
                    case .toggle:
                        FlagRow(
                            flag: flag,
                            isActive: Binding(
                                get: { viewModel.flags[flag.key] ?? false },
                                set: { _ in viewModel.toggleFlag(flag.key) }
                            )
                        )
                    case .rating:
                        // Skip rating flags in add form - can set in detail view
                        EmptyView()
                    }
                }
            } header: {
                Text("Status")
            }
        }
    }

    // MARK: - Notes Section

    @ViewBuilder
    private func notesSection(viewModel: AddEditItemViewModel) -> some View {
        Section {
            TextEditor(text: Binding(
                get: { viewModel.notes },
                set: { viewModel.notes = $0 }
            ))
            .frame(minHeight: 100)
        } header: {
            Text("Notes")
        }
    }

    // MARK: - Options Section

    @ViewBuilder
    private func optionsSection(viewModel: AddEditItemViewModel) -> some View {
        Section {
            Toggle(isOn: Binding(
                get: { viewModel.isFavorite },
                set: { viewModel.isFavorite = $0 }
            )) {
                Label("Favorite", systemImage: "heart")
            }
        }
    }

    // MARK: - Helpers

    private var commonTagSuggestions: [String] {
        [
            "favorite", "must-try", "highly-rated",
            "quick", "easy", "weekend",
            "gift-idea", "wishlist", "reference"
        ]
    }
}

// MARK: - Category Picker Item

struct CategoryPickerItem: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            VStack(spacing: DesignTokens.Spacing.xs) {
                CategoryIcon(
                    self.category,
                    size: .medium,
                    style: self.isSelected ? .filled : .circle
                )

                Text(self.category.rawValue)
                    .font(DesignTokens.Typography.caption2)
                    .lineLimit(1)
            }
            .frame(width: 70)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background {
                if self.isSelected {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                        .fill(self.category.color.opacity(0.15))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("AddEditItemSheet - Add") {
    AddEditItemSheet()
        .modelContainer(for: [StashItem.self, Tag.self], inMemory: true)
        .environment(AppCoordinator())
}

#Preview("AddEditItemSheet - Add Recipe") {
    AddEditItemSheet(initialCategory: .recipe)
        .modelContainer(for: [StashItem.self, Tag.self], inMemory: true)
        .environment(AppCoordinator())
}

#Preview("AddEditItemSheet - Edit") {
    let container = try! ModelContainer(
        for: StashItem.self, Tag.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext
    let item = StashItem(
        title: "Chocolate Chip Cookies",
        category: .recipe,
        sourceURL: URL(string: "https://cooking.nytimes.com/recipes/123")
    )
    item.notes = "Grandma's recipe"
    context.insert(item)

    return AddEditItemSheet(existingItem: item)
        .modelContainer(container)
        .environment(AppCoordinator())
}
