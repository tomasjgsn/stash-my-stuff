//
//  ItemDetailViewModel.swift
//  StashMyStuff
//
//  ViewModel for the Item Detail screen. Manages item state,
//  editing, and actions like opening links and deleting.
//

import Foundation
import Observation
import SwiftData
#if canImport(UIKit)
    import UIKit
#endif

@Observable
@MainActor
final class ItemDetailViewModel {
    // MARK: - Dependencies

    private let repository: StashRepository
    private(set) var item: StashItem

    // MARK: - State

    var isEditing = false
    var showDeleteConfirmation = false
    var isDeleted = false

    // Edit state (temporary values while editing)
    var editTitle = ""
    var editNotes = ""
    var editSourceURL = ""
    var editTags: [String] = []

    // MARK: - Computed Properties

    var categoryConfig: CategoryConfig? {
        CategoryConfig.config(for: self.item.category)
    }

    var formattedDate: String {
        self.item.dateAdded.formatted(date: .abbreviated, time: .omitted)
    }

    var canOpenLink: Bool {
        self.item.sourceURL != nil
    }

    var sourceDomain: String? {
        self.item.sourceDomain
    }

    var tagNames: [String] {
        self.item.tags.map(\.name)
    }

    // MARK: - Initialization

    init(item: StashItem, repository: StashRepository) {
        self.item = item
        self.repository = repository
    }

    // MARK: - Actions

    func toggleFavorite() {
        self.item.isFavorite.toggle()
        self.save()
        HapticService.shared.favoriteToggled(isFavorite: self.item.isFavorite)
    }

    func toggleFlag(_ flagKey: String) {
        let currentValue = self.item.flags[flagKey] ?? false
        self.item.flags[flagKey] = !currentValue
        self.save()
        HapticService.shared.flagToggled(isNowActive: !currentValue)
    }

    func setRating(_ flagKey: String, value: Int) {
        self.item.metadata[flagKey] = String(value)
        self.save()
        HapticService.shared.selectionChanged()
    }

    func getRating(_ flagKey: String) -> Int {
        guard let value = self.item.metadata[flagKey] else { return 0 }
        return Int(value) ?? 0
    }

    func openLink() {
        guard let url = self.item.sourceURL else { return }

        #if os(iOS)
            UIApplication.shared.open(url)
        #elseif os(macOS)
            NSWorkspace.shared.open(url)
        #endif
    }

    // MARK: - Editing

    func startEditing() {
        self.editTitle = self.item.title
        self.editNotes = self.item.notes
        self.editSourceURL = self.item.sourceURL?.absoluteString ?? ""
        self.editTags = self.item.tags.map(\.name)
        self.isEditing = true
    }

    func cancelEditing() {
        self.isEditing = false
    }

    func saveEdits() {
        self.item.title = self.editTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        self.item.notes = self.editNotes

        if !self.editSourceURL.isEmpty {
            self.item.sourceURL = URL(string: self.editSourceURL)
        } else {
            self.item.sourceURL = nil
        }

        // Tags would need more complex handling (creating/finding existing tags)
        // This is simplified - full implementation would use the repository

        self.save()
        self.isEditing = false
        HapticService.shared.itemSaved()
    }

    // MARK: - Deletion

    func confirmDelete() {
        self.showDeleteConfirmation = true
    }

    func delete() {
        self.repository.delete(self.item)
        self.isDeleted = true
        HapticService.shared.itemDeleted()
    }

    // MARK: - Private

    private func save() {
        self.repository.save(self.item)
    }
}
