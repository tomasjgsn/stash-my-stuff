//
//  StashMyStuffTests.swift
//  StashMyStuffTests
//
//  Phase 1: Data Layer Tests
//  Comprehensive tests for StashItem, Tag, CategoryConfig, and Repository
//

import Foundation
import Testing
import SwiftData
@testable import StashMyStuff

// Use typealias to avoid ambiguity with system Category type
typealias ItemCategory = StashMyStuff.Category

// MARK: - Test Configuration

/// Helper to create an in-memory model container for testing
@MainActor
func createTestContainer() -> ModelContainer {
    let schema = Schema([StashItem.self, Tag.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    return try! ModelContainer(for: schema, configurations: [configuration])
}

// MARK: - StashItem Model Tests

@Suite("StashItem Model Tests")
struct StashItemTests {

    @Test("Create a basic StashItem")
    @MainActor
    func testCreateStashItem() {
        let item = StashItem(
            title: "Gochujang Chicken",
            category: ItemCategory.recipe,
            sourceURL: URL(string: "https://cooking.nytimes.com/recipes")
        )

        #expect(item.title == "Gochujang Chicken")
        #expect(item.category == ItemCategory.recipe)
        #expect(item.sourceURL?.absoluteString == "https://cooking.nytimes.com/recipes")
        #expect(item.notes == "")
        #expect(item.isFavorite == false)
        #expect(item.tags.isEmpty)
        #expect(item.flags.isEmpty)
        #expect(item.metadata.isEmpty)
    }

    @Test("Source domain extraction")
    @MainActor
    func testSourceDomain() {
        let item1 = StashItem(
            title: "Recipe",
            category: ItemCategory.recipe,
            sourceURL: URL(string: "https://cooking.nytimes.com/recipes/1234")
        )
        #expect(item1.sourceDomain == "cooking.nytimes.com")

        let item2 = StashItem(
            title: "Book",
            category: ItemCategory.book,
            sourceURL: nil
        )
        #expect(item2.sourceDomain == nil)
    }

    @Test("Flag manipulation")
    @MainActor
    func testFlags() {
        let item = StashItem(
            title: "Test Recipe",
            category: ItemCategory.recipe,
            sourceURL: nil
        )

        // Initially empty
        #expect(item.flags.isEmpty)

        // Set flags
        item.flags["hasBeenCooked"] = true
        item.flags["wouldCookAgain"] = false

        #expect(item.flags["hasBeenCooked"] == true)
        #expect(item.flags["wouldCookAgain"] == false)
        #expect(item.flags["writtenIntoRecipeBook"] == nil)

        // Safe access with default
        let cooked = item.flags["hasBeenCooked"] ?? false
        #expect(cooked == true)
    }

    @Test("Metadata storage")
    @MainActor
    func testMetadata() {
        let item = StashItem(
            title: "Test Book",
            category: ItemCategory.book,
            sourceURL: nil
        )

        item.metadata["rating"] = "5"
        item.metadata["pageCount"] = "320"

        #expect(item.metadata["rating"] == "5")
        #expect(item.metadata["pageCount"] == "320")
        #expect(item.metadata["author"] == nil)
    }

    @Test("Favoriting items")
    @MainActor
    func testFavorite() {
        let item = StashItem(
            title: "Test",
            category: ItemCategory.recipe,
            sourceURL: nil
        )

        #expect(item.isFavorite == false)

        item.isFavorite = true
        #expect(item.isFavorite == true)
    }
}

// MARK: - Tag Model Tests

@Suite("Tag Model Tests")
struct TagTests {

    @Test("Create a tag")
    @MainActor
    func testCreateTag() {
        let tag = Tag(name: "favorite")

        #expect(tag.name == "favorite")
        #expect(tag.items.isEmpty)
    }

    @Test("Tag-Item relationship")
    @MainActor
    func testTagRelationship() {
        let tag = Tag(name: "quick")
        let item1 = StashItem(title: "Recipe 1", category: ItemCategory.recipe, sourceURL: nil)
        let item2 = StashItem(title: "Recipe 2", category: ItemCategory.recipe, sourceURL: nil)

        // Add items to tag
        tag.items.append(item1)
        tag.items.append(item2)

        #expect(tag.items.count == 2)
        #expect(tag.items.contains(item1))

        // Add tag to item
        item1.tags.append(tag)
        #expect(item1.tags.count == 1)
        #expect(item1.tags.first?.name == "quick")
    }
}

// MARK: - Category Enum Tests

@Suite("Category Enum Tests")
struct CategoryTests {

    @Test("All categories are defined")
    func testAllCategories() {
        let allCategories = ItemCategory.allCases
        #expect(allCategories.count == 10)
    }

    @Test("Category raw values")
    func testCategoryRawValues() {
        #expect(ItemCategory.recipe.rawValue == "Recipes")
        #expect(ItemCategory.book.rawValue == "Books")
        #expect(ItemCategory.movie.rawValue == "Movies & TV")
        #expect(ItemCategory.music.rawValue == "Music")
        #expect(ItemCategory.clothes.rawValue == "Clothes")
        #expect(ItemCategory.home.rawValue == "Home")
        #expect(ItemCategory.article.rawValue == "Articles")
        #expect(ItemCategory.podcast.rawValue == "Podcasts")
        #expect(ItemCategory.trip.rawValue == "Trips")
        #expect(ItemCategory.backpack.rawValue == "Backpack")
    }
}

// MARK: - Category Configuration Tests

@Suite("Category Configuration Tests")
struct CategoryConfigTests {

    @Test("All categories have configs")
    func testAllCategoriesConfigured() {
        #expect(categoryConfigs.count == 10)

        for category in ItemCategory.allCases {
            let config = CategoryConfig.config(for: category)
            #expect(config != nil)
            #expect(config?.category == category)
        }
    }

    @Test("Recipe configuration")
    func testRecipeConfig() {
        let config = CategoryConfig.config(for: ItemCategory.recipe)

        #expect(config?.category == ItemCategory.recipe)
        #expect(config?.icon == "fork.knife")
        #expect(config?.color == "orange")
        #expect(config?.flags.count == 3)

        let flagKeys = config?.flags.map { $0.key }
        #expect(flagKeys?.contains("hasBeenCooked") == true)
        #expect(flagKeys?.contains("wouldCookAgain") == true)
        #expect(flagKeys?.contains("writtenIntoRecipeBook") == true)
    }

    @Test("Book configuration has rating")
    func testBookRating() {
        let config = CategoryConfig.config(for: ItemCategory.book)
        let ratingFlag = config?.flags.first { $0.key == "rating" }

        #expect(ratingFlag != nil)
        #expect(ratingFlag?.type == .rating)
    }

    @Test("Flag consistency across categories")
    func testFlagConsistency() {
        // "hasBought" should be consistent wherever it appears
        let bookConfig = CategoryConfig.config(for: ItemCategory.book)
        let musicConfig = CategoryConfig.config(for: ItemCategory.music)

        let bookBought = bookConfig?.flags.first { $0.key == "hasBought" }
        let musicBought = musicConfig?.flags.first { $0.key == "hasBought" }

        #expect(bookBought?.label == musicBought?.label)
        #expect(bookBought?.icon == musicBought?.icon)
    }
}

// MARK: - Repository Tests

@Suite("Repository Tests")
struct RepositoryTests {

    @Test("Save and fetch item")
    @MainActor
    func testSaveAndFetch() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        let item = StashItem(
            title: "Test Item",
            category: ItemCategory.recipe,
            sourceURL: nil
        )

        repository.save(item)

        let allItems = repository.fetchAll()
        #expect(allItems.count == 1)
        #expect(allItems.first?.title == "Test Item")
    }

    @Test("Fetch by category")
    @MainActor
    func testFetchByCategory() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        repository.save(StashItem(title: "Recipe", category: ItemCategory.recipe, sourceURL: nil))
        repository.save(StashItem(title: "Book", category: ItemCategory.book, sourceURL: nil))
        repository.save(StashItem(title: "Another Recipe", category: ItemCategory.recipe, sourceURL: nil))

        let recipes = repository.fetchByCategory(ItemCategory.recipe)
        #expect(recipes.count == 2)

        let books = repository.fetchByCategory(ItemCategory.book)
        #expect(books.count == 1)
    }

    @Test("Fetch favorites")
    @MainActor
    func testFetchFavorites() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        let item1 = StashItem(title: "Favorite", category: ItemCategory.recipe, sourceURL: nil)
        item1.isFavorite = true

        let item2 = StashItem(title: "Not Favorite", category: ItemCategory.recipe, sourceURL: nil)

        repository.save(item1)
        repository.save(item2)

        let favorites = repository.fetchFavorites()
        #expect(favorites.count == 1)
        #expect(favorites.first?.title == "Favorite")
    }

    @Test("Fetch uncooked recipes")
    @MainActor
    func testFetchUncookedRecipes() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        let cooked = StashItem(title: "Cooked", category: ItemCategory.recipe, sourceURL: nil)
        cooked.flags["hasBeenCooked"] = true

        let uncooked = StashItem(title: "Uncooked", category: ItemCategory.recipe, sourceURL: nil)

        repository.save(cooked)
        repository.save(uncooked)

        let uncookedRecipes = repository.fetchUncookedRecipes()
        #expect(uncookedRecipes.count == 1)
        #expect(uncookedRecipes.first?.title == "Uncooked")
    }

    @Test("Fetch to-read books")
    @MainActor
    func testFetchToRead() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        // Owned but unread
        let toRead = StashItem(title: "To Read", category: ItemCategory.book, sourceURL: nil)
        toRead.flags["hasBought"] = true
        toRead.flags["hasRead"] = false

        // Owned and read
        let alreadyRead = StashItem(title: "Already Read", category: ItemCategory.book, sourceURL: nil)
        alreadyRead.flags["hasBought"] = true
        alreadyRead.flags["hasRead"] = true

        // Not owned yet
        let wishlist = StashItem(title: "Wishlist", category: ItemCategory.book, sourceURL: nil)

        repository.save(toRead)
        repository.save(alreadyRead)
        repository.save(wishlist)

        let booksToRead = repository.fetchToRead()
        #expect(booksToRead.count == 1)
        #expect(booksToRead.first?.title == "To Read")
    }

    @Test("Fetch Bandcamp queue")
    @MainActor
    func testFetchBandcampQueue() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        // Want to buy but haven't
        let inQueue = StashItem(title: "In Queue", category: ItemCategory.music, sourceURL: nil)
        inQueue.flags["wantToPurchase"] = true
        inQueue.flags["hasBought"] = false

        // Already purchased
        let purchased = StashItem(title: "Purchased", category: ItemCategory.music, sourceURL: nil)
        purchased.flags["wantToPurchase"] = true
        purchased.flags["hasBought"] = true

        repository.save(inQueue)
        repository.save(purchased)

        let queue = repository.fetchBandcampQueue()
        #expect(queue.count == 1)
        #expect(queue.first?.title == "In Queue")
    }

    @Test("Fetch unwatched movies")
    @MainActor
    func testFetchUnwatchedMovies() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        let watched = StashItem(title: "Watched", category: ItemCategory.movie, sourceURL: nil)
        watched.flags["hasWatched"] = true

        let unwatched = StashItem(title: "Unwatched", category: ItemCategory.movie, sourceURL: nil)

        repository.save(watched)
        repository.save(unwatched)

        let unwatchedMovies = repository.fetchUnwatchedMovies()
        #expect(unwatchedMovies.count == 1)
        #expect(unwatchedMovies.first?.title == "Unwatched")
    }

    @Test("Search functionality")
    @MainActor
    func testSearch() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        let item1 = StashItem(title: "Chicken Curry", category: ItemCategory.recipe, sourceURL: nil)
        let item2 = StashItem(title: "Beef Stew", category: ItemCategory.recipe, sourceURL: nil)
        item2.notes = "uses chicken stock"

        repository.save(item1)
        repository.save(item2)

        let results = repository.search(query: "chicken")
        #expect(results.count == 2)  // Matches title and notes

        let beefResults = repository.search(query: "beef")
        #expect(beefResults.count == 1)
    }

    @Test("Delete item")
    @MainActor
    func testDelete() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        let item = StashItem(title: "To Delete", category: ItemCategory.recipe, sourceURL: nil)
        repository.save(item)

        #expect(repository.fetchAll().count == 1)

        repository.delete(item)

        #expect(repository.fetchAll().count == 0)
    }

    @Test("Fetch recent items")
    @MainActor
    func testFetchRecent() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        // Create item added today
        let recentItem = StashItem(title: "Recent", category: ItemCategory.recipe, sourceURL: nil)
        repository.save(recentItem)

        let recent = repository.fetchRecent(days: 7)
        #expect(recent.count == 1)

        let recent30 = repository.fetchRecent(days: 30)
        #expect(recent30.count == 1)
    }

    @Test("Fetch with custom sorting")
    @MainActor
    func testCustomSorting() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        repository.save(StashItem(title: "Zebra", category: ItemCategory.recipe, sourceURL: nil))
        repository.save(StashItem(title: "Apple", category: ItemCategory.recipe, sourceURL: nil))
        repository.save(StashItem(title: "Banana", category: ItemCategory.recipe, sourceURL: nil))

        let byTitle = repository.fetchByCategory(ItemCategory.recipe, sortedBy: .title)
        #expect(byTitle.first?.title == "Apple")
        #expect(byTitle.last?.title == "Zebra")
    }

    @Test("Fetch completed items")
    @MainActor
    func testFetchCompleted() {
        let container = createTestContainer()
        let context = container.mainContext
        let repository = StashRepository(modelContext: context)

        let cooked = StashItem(title: "Cooked Recipe", category: ItemCategory.recipe, sourceURL: nil)
        cooked.flags["hasBeenCooked"] = true

        let uncooked = StashItem(title: "Uncooked Recipe", category: ItemCategory.recipe, sourceURL: nil)

        repository.save(cooked)
        repository.save(uncooked)

        let completed = repository.fetchCompleted(in: ItemCategory.recipe)
        #expect(completed.count == 1)
        #expect(completed.first?.title == "Cooked Recipe")
    }
}
