import Foundation
@testable import StashMyStuff

enum MockFactories {
    /// Creates a mock StashItem for testing
    static func createMockStashItem(
        title: String = "Test Item",
        category: StashMyStuff.Category = .recipe,
        sourceURL: URL? = nil,
        notes: String = "",
        isFavorite: Bool = false
    ) -> StashItem {
        let item = StashItem(title: title, category: category, sourceURL: sourceURL)
        item.notes = notes
        item.isFavorite = isFavorite
        return item
    }

    /// Creates a mock Tag for testing
    static func createMockTag(name: String = "test-tag") -> Tag {
        Tag(name: name)
    }

    /// Creates a mock recipe for testing
    static func createMockRecipe(
        title: String = "Test Recipe",
        isCooked: Bool = false,
        wouldCookAgain: Bool = false
    ) -> StashItem {
        let item = self.createMockStashItem(title: title, category: StashMyStuff.Category.recipe)
        if isCooked {
            item.flags["hasBeenCooked"] = true
        }
        if wouldCookAgain {
            item.flags["wouldCookAgain"] = true
        }
        return item
    }

    /// Creates a mock book for testing
    static func createMockBook(
        title: String = "Test Book",
        hasBought: Bool = false,
        hasRead: Bool = false,
        rating: Int? = nil
    ) -> StashItem {
        let item = self.createMockStashItem(title: title, category: StashMyStuff.Category.book)
        if hasBought {
            item.flags["hasBought"] = true
        }
        if hasRead {
            item.flags["hasRead"] = true
        }
        if let rating {
            item.metadata["rating"] = String(rating)
        }
        return item
    }
}
