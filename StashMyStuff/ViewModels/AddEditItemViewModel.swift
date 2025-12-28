//
//  AddEditItemViewModel.swift
//  StashMyStuff
//
//  ViewModel for the Add/Edit Item sheet. Handles form state,
//  validation, and saving new or edited items.
//

import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class AddEditItemViewModel {
    // MARK: - Dependencies

    private let repository: StashRepository
    private let existingItem: StashItem?

    // MARK: - Form State

    var title = ""
    var sourceURL = ""
    var selectedCategory: Category
    var notes = ""
    var isFavorite = false
    var tags: [String] = []
    var flags: [String: Bool] = [:]

    // MARK: - UI State

    var isLoading = false
    var errorMessage: String?
    var didSave = false

    // MARK: - Computed Properties

    var isEditing: Bool {
        self.existingItem != nil
    }

    var navigationTitle: String {
        self.isEditing ? "Edit Item" : "Add Item"
    }

    var saveButtonTitle: String {
        self.isEditing ? "Save" : "Add"
    }

    var isValid: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var categoryConfig: CategoryConfig? {
        CategoryConfig.config(for: self.selectedCategory)
    }

    var availableFlags: [FlagDefinition] {
        self.categoryConfig?.flags ?? []
    }

    // URL validation
    var parsedURL: URL? {
        guard !self.sourceURL.isEmpty else { return nil }

        // Add https:// if no scheme provided
        var urlString = self.sourceURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if !urlString.contains("://") {
            urlString = "https://\(urlString)"
        }

        return URL(string: urlString)
    }

    var isURLValid: Bool {
        self.sourceURL.isEmpty || self.parsedURL != nil
    }

    // MARK: - Initialization

    init(
        repository: StashRepository,
        existingItem: StashItem? = nil,
        initialCategory: Category? = nil
    ) {
        self.repository = repository
        self.existingItem = existingItem

        if let item = existingItem {
            // Editing existing item
            self.selectedCategory = item.category
            self.title = item.title
            self.sourceURL = item.sourceURL?.absoluteString ?? ""
            self.notes = item.notes
            self.isFavorite = item.isFavorite
            self.tags = item.tags.map(\.name)
            self.flags = item.flags
        } else {
            // New item
            self.selectedCategory = initialCategory ?? .backpack
        }
    }

    // MARK: - Actions

    func save() {
        guard self.isValid else {
            self.errorMessage = "Please enter a title"
            return
        }

        guard self.isURLValid else {
            self.errorMessage = "Please enter a valid URL"
            return
        }

        self.isLoading = true
        self.errorMessage = nil

        let trimmedTitle = self.title.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existing = self.existingItem {
            // Update existing item
            existing.title = trimmedTitle
            existing.sourceURL = self.parsedURL
            existing.notes = self.notes
            existing.isFavorite = self.isFavorite
            existing.flags = self.flags
            // Tags would need more complex handling

            self.repository.save(existing)
        } else {
            // Create new item
            let newItem = StashItem(
                title: trimmedTitle,
                category: self.selectedCategory,
                sourceURL: self.parsedURL
            )
            newItem.notes = self.notes
            newItem.isFavorite = self.isFavorite
            newItem.flags = self.flags

            self.repository.save(newItem)
        }

        self.isLoading = false
        self.didSave = true
        HapticService.shared.itemSaved()
    }

    func toggleFlag(_ flagKey: String) {
        let currentValue = self.flags[flagKey] ?? false
        self.flags[flagKey] = !currentValue
        HapticService.shared.flagToggled(isNowActive: !currentValue)
    }

    func addTag(_ tag: String) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !self.tags.contains(trimmed) else { return }
        self.tags.append(trimmed)
    }

    func removeTag(_ tag: String) {
        self.tags.removeAll { $0 == tag }
    }

    func clearError() {
        self.errorMessage = nil
    }
}
