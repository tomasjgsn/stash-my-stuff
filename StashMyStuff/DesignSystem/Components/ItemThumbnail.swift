//
//  ItemThumbnail.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Item Thumbnail

/// Displays an item's thumbnail image with loading and error states
struct ItemThumbnail: View {
    let url: URL?
    let category: Category
    let size: ThumbnailSize

    enum ThumbnailSize {
        case small // 44pt - for compact lists
        case medium // 60pt - for standard lists
        case large // 80pt - for featured items
        case hero // 120pt - for detail headers

        var dimension: CGFloat {
            switch self {
            case .small: 44
            case .medium: 60
            case .large: 80
            case .hero: 120
            }
        }

        var cornerRadius: CGFloat {
            switch self {
            case .small: DesignTokens.Radius.sm
            case .medium: DesignTokens.Radius.md
            case .large: DesignTokens.Radius.lg
            case .hero: DesignTokens.Radius.xl
            }
        }

        var iconSize: CGFloat {
            switch self {
            case .small: 20
            case .medium: 24
            case .large: 32
            case .hero: 44
            }
        }
    }

    init(url: URL?, category: Category, size: ThumbnailSize = .medium) {
        self.url = url
        self.category = category
        self.size = size
    }

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        self.placeholderView
                            .overlay {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        self.placeholderView
                    @unknown default:
                        self.placeholderView
                    }
                }
            } else {
                self.placeholderView
            }
        }
        .frame(width: self.size.dimension, height: self.size.dimension)
        .clipShape(RoundedRectangle(cornerRadius: self.size.cornerRadius))
    }

    private var placeholderView: some View {
        ZStack {
            self.category.color.opacity(0.15)

            if let config = CategoryConfig.config(for: self.category) {
                Image(systemName: config.icon)
                    .font(.system(size: self.size.iconSize))
                    .foregroundStyle(self.category.color)
            }
        }
    }
}

// MARK: - Preview

#Preview("ItemThumbnail") {
    VStack(spacing: DesignTokens.Spacing.lg) {
        // With image URL
        HStack(spacing: DesignTokens.Spacing.md) {
            ItemThumbnail(
                url: URL(string: "https://picsum.photos/200"),
                category: .recipe,
                size: .small
            )
            ItemThumbnail(
                url: URL(string: "https://picsum.photos/200"),
                category: .recipe,
                size: .medium
            )
            ItemThumbnail(
                url: URL(string: "https://picsum.photos/200"),
                category: .recipe,
                size: .large
            )
        }

        Divider()

        // Placeholders (no URL)
        HStack(spacing: DesignTokens.Spacing.md) {
            ForEach(Category.allCases.prefix(5), id: \.self) { category in
                ItemThumbnail(url: nil, category: category, size: .medium)
            }
        }

        Divider()

        // Hero size
        ItemThumbnail(url: nil, category: .book, size: .hero)
    }
    .padding()
}
