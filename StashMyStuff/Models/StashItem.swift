//
//  StashItem.swift
//  StashMyStuff
//
//  Created by Tomas Juergensen on 26/12/2025.
//

import Foundation
import SwiftData

// Category enum
enum Category: String, Codable, CaseIterable {
    case recipe = "Recipes"
    case book = "Books"
    case movie = "Movies & TV"
    case music = "Music"
    case clothes = "Clothes"
    case home = "Home"
    case article = "Articles"
    case podcast = "Podcasts"
    case trip = "Trips"
    case backpack = "Backpack"
}

// Tag model
@Model
class Tag {
    var name: String
    var items: [StashItem] // Many-to-many: a tag belongs to many items

    init(name: String) {
        self.name = name
        self.items = []
    }
}

// StashItem model
@Model
class StashItem {
    var title: String
    var sourceURL: URL?
    var imageURL: URL?
    var category: Category
    var notes: String
    var isFavorite: Bool
    var dateAdded: Date
    var tags: [Tag]
    var flags: [String: Bool]
    var metadata: [String: String]

    // Computed properties
    var sourceDomain: String? {
        self.sourceURL?.host() // Returns the domain from a URL
    }

    // Initialiser
    init(title: String, category: Category, sourceURL: URL?) {
        self.title = title
        self.category = category
        self.sourceURL = sourceURL
        self.imageURL = nil
        self.notes = ""
        self.isFavorite = false
        self.dateAdded = Date()
        self.tags = []
        self.flags = [:]
        self.metadata = [:]
    }
}
