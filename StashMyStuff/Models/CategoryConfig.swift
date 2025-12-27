//
//  CategoryConfig.swift
//  StashMyStuff
//
//  Created by Tomas Juergensen on 26/12/2025.
//

import Foundation

enum FlagType {
    case toggle // Boolean on/off
    case rating // 1-5 stars
}

struct FlagDefinition {
    let key: String
    let label: String
    let icon: String
    let type: FlagType
}

struct CategoryConfig {
    let category: Category
    let icon: String
    let color: String
    let flags: [FlagDefinition]
}

let categoryConfigs: [CategoryConfig] = [
    // 1. RECIPES
    CategoryConfig(
        category: .recipe,
        icon: "fork.knife",
        color: "orange",
        flags: [
            FlagDefinition(
                key: "hasBeenCooked",
                label: "Cooked it",
                icon: "flame.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "wouldCookAgain",
                label: "Would make again",
                icon: "star.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "writtenIntoRecipeBook",
                label: "In recipe book",
                icon: "book.fill",
                type: .toggle
            )
        ]
    ),

    // 2. BOOKS
    CategoryConfig(
        category: .book,
        icon: "book.fill",
        color: "indigo",
        flags: [
            FlagDefinition(
                key: "hasBought",
                label: "Own it",
                icon: "shippingbox.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "hasRead",
                label: "Finished reading",
                icon: "checkmark.circle.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "rating",
                label: "Rating",
                icon: "star.fill",
                type: .rating
            )
        ]
    ),

    // 3. MOVIES & TV
    CategoryConfig(
        category: .movie,
        icon: "film.fill",
        color: "purple",
        flags: [
            FlagDefinition(
                key: "hasWatched",
                label: "Watched it",
                icon: "checkmark.circle.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "rating",
                label: "Rating",
                icon: "star.fill",
                type: .rating
            )
        ]
    ),

    // 4. MUSIC
    CategoryConfig(
        category: .music,
        icon: "music.note",
        color: "pink",
        flags: [
            FlagDefinition(
                key: "hasListened",
                label: "Listened to it",
                icon: "checkmark.circle.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "wantToPurchase",
                label: "Want to buy it",
                icon: "shippingbox.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "hasBought",
                label: "Own it",
                icon: "shippingbox.fill",
                type: .toggle
            )
        ]
    ),

    // 5. CLOTHES
    CategoryConfig(
        category: .clothes,
        icon: "tshirt.fill",
        color: "teal",
        flags: [
            FlagDefinition(
                key: "wantToBuy",
                label: "Want to buy",
                icon: "heart",
                type: .toggle
            ),
            FlagDefinition(
                key: "hasBought",
                label: "Own it",
                icon: "shippingbox.fill",
                type: .toggle
            )
        ]
    ),

    // 6. HOME
    CategoryConfig(
        category: .home,
        icon: "house.fill",
        color: "brown",
        flags: [
            FlagDefinition(
                key: "isInspiration",
                label: "Inspiring",
                icon: "lightbulb",
                type: .toggle
            ),
            FlagDefinition(
                key: "wantToPurchase",
                label: "Want to buy it",
                icon: "shoppingbox.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "hasBought",
                label: "Own it",
                icon: "shippingbox.fill",
                type: .toggle
            )
        ]
    ),

    // 7. ARTICLES
    CategoryConfig(
        category: .article,
        icon: "doc.text.fill",
        color: "blue",
        flags: [
            FlagDefinition(
                key: "hasRead",
                label: "Finished reading",
                icon: "checkmark.circle.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "isInspiration",
                label: "Inspiring",
                icon: "lightbulb",
                type: .toggle
            ),
            FlagDefinition(
                key: "isTechnical",
                label: "Technical Documentation",
                icon: "questionmark.circle",
                type: .toggle
            )
        ]
    ),

    // 8. PODCASTS
    CategoryConfig(
        category: .podcast,
        icon: "mic.fill",
        color: "green",
        flags: [
            FlagDefinition(
                key: "hasListened",
                label: "Listened to it",
                icon: "checkmark.circle.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "isSubscribed",
                label: "Subscribed",
                icon: "bell.fill",
                type: .toggle
            )
        ]
    ),

    // 9. TRIPS
    CategoryConfig(
        category: .trip,
        icon: "airplane",
        color: "cyan",
        flags: [
            FlagDefinition(
                key: "wantToVisit",
                label: "Want to visit",
                icon: "heart.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "hasVisited",
                label: "Visited",
                icon: "checkmark.circle.fill",
                type: .toggle
            )
        ]
    ),

    // 10. BACKPACK
    CategoryConfig(
        category: .backpack,
        icon: "backpack.fill",
        color: "gray",
        flags: [
            FlagDefinition(
                key: "hasReviewed",
                label: "Reviewed",
                icon: "checkmark.circle.fill",
                type: .toggle
            ),
            FlagDefinition(
                key: "isReference",
                label: "Reference",
                icon: "bookmark.fill",
                type: .toggle
            )
        ]
    )
]

extension CategoryConfig {
    static func config(for category: Category) -> CategoryConfig? {
        categoryConfigs.first(where: { $0.category == category })
    }
}
