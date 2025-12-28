//
//  TagInput.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Flow Layout

/// A layout that arranges views in rows, wrapping to new lines as needed
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var alignment: HorizontalAlignment = .leading

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let result = self.computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let result = self.computeLayout(proposal: proposal, subviews: subviews)

        for (index, position) in result.positions.enumerated() {
            let adjustedX: CGFloat
            switch self.alignment {
            case .center:
                let rowWidth = result.rowWidths[result.rowIndices[index]]
                adjustedX = bounds.minX + position.x + (bounds.width - rowWidth) / 2
            case .trailing:
                let rowWidth = result.rowWidths[result.rowIndices[index]]
                adjustedX = bounds.minX + position.x + (bounds.width - rowWidth)
            default:
                adjustedX = bounds.minX + position.x
            }

            subviews[index].place(
                at: CGPoint(x: adjustedX, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func computeLayout(
        proposal: ProposedViewSize,
        subviews: Subviews
    ) -> (size: CGSize, positions: [CGPoint], rowWidths: [CGFloat], rowIndices: [Int]) {
        let maxWidth = proposal.width ?? .infinity

        var positions: [CGPoint] = []
        var rowWidths: [CGFloat] = []
        var rowIndices: [Int] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var currentRowWidth: CGFloat = 0
        var currentRowIndex = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            // Check if we need to wrap to new line
            if currentX + size.width > maxWidth, currentX > 0 {
                rowWidths.append(currentRowWidth - self.spacing)
                currentX = 0
                currentY += lineHeight + self.spacing
                lineHeight = 0
                currentRowWidth = 0
                currentRowIndex += 1
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            rowIndices.append(currentRowIndex)
            currentX += size.width + self.spacing
            currentRowWidth = currentX
            lineHeight = max(lineHeight, size.height)
        }

        // Add last row width
        if currentRowWidth > 0 {
            rowWidths.append(currentRowWidth - self.spacing)
        }

        let totalSize = CGSize(
            width: maxWidth,
            height: currentY + lineHeight
        )

        return (totalSize, positions, rowWidths, rowIndices)
    }
}

// MARK: - Tag Input

/// An input field for adding tags with autocomplete suggestions
struct TagInput: View {
    @Binding
    var tags: [String]
    let suggestions: [String]
    let placeholder: String
    let maxTags: Int?

    @State
    private var inputText = ""
    @FocusState
    private var isInputFocused: Bool
    @State
    private var showSuggestions = false

    init(
        tags: Binding<[String]>,
        suggestions: [String] = [],
        placeholder: String = "Add tag...",
        maxTags: Int? = nil
    ) {
        self._tags = tags
        self.suggestions = suggestions
        self.placeholder = placeholder
        self.maxTags = maxTags
    }

    // Filter suggestions based on input
    private var filteredSuggestions: [String] {
        guard !self.inputText.isEmpty else { return [] }
        let lowercasedInput = self.inputText.lowercased()
        return self.suggestions
            .filter { suggestion in
                suggestion.lowercased().contains(lowercasedInput) &&
                    !self.tags.contains(suggestion)
            }
            .prefix(5)
            .map(\.self)
    }

    private var isAtMaxTags: Bool {
        guard let max = self.maxTags else { return false }
        return self.tags.count >= max
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            // Current tags
            if !self.tags.isEmpty {
                FlowLayout(spacing: DesignTokens.Spacing.xs) {
                    ForEach(self.tags, id: \.self) { tag in
                        TagChip(tag) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                self.tags.removeAll { $0 == tag }
                            }
                        }
                    }
                }
            }

            // Max tags message (Exercise 2)
            if self.isAtMaxTags {
                Text("Maximum \(self.maxTags ?? 0) tags reached")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.orange)
            }

            // Input field
            if !self.isAtMaxTags {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Image(systemName: "tag")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)

                    TextField(self.placeholder, text: self.$inputText)
                        .font(DesignTokens.Typography.body)
                        .focused(self.$isInputFocused)
                        .onSubmit {
                            self.addTag()
                        }
                        .onChange(of: self.inputText) { _, newValue in
                            self.showSuggestions = !newValue.isEmpty
                        }

                    if !self.inputText.isEmpty {
                        Button {
                            self.inputText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(DesignTokens.Spacing.sm)
                .background {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                        .fill(Color(.systemGray6))
                }
            }

            // Suggestions dropdown
            if self.showSuggestions, !self.filteredSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(self.filteredSuggestions, id: \.self) { suggestion in
                        Button {
                            self.selectSuggestion(suggestion)
                        } label: {
                            HStack {
                                Text(suggestion)
                                    .font(DesignTokens.Typography.body)
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, DesignTokens.Spacing.sm)
                            .padding(.vertical, DesignTokens.Spacing.xs)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if suggestion != self.filteredSuggestions.last {
                            Divider()
                                .padding(.leading, DesignTokens.Spacing.sm)
                        }
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                }
            }
        }
    }

    private func addTag() {
        let trimmed = self.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !self.tags.contains(trimmed) else {
            self.inputText = ""
            return
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            self.tags.append(trimmed)
        }
        self.inputText = ""
        self.showSuggestions = false
    }

    private func selectSuggestion(_ suggestion: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            self.tags.append(suggestion)
        }
        self.inputText = ""
        self.showSuggestions = false
        self.isInputFocused = true // Keep focus for adding more
    }
}

// MARK: - Tag Display (Read-Only)

/// Displays tags in a flow layout without editing capability
struct TagDisplay: View {
    let tags: [String]
    let color: Color
    let maxVisible: Int?

    init(
        _ tags: [String],
        color: Color = .accentColor,
        maxVisible: Int? = nil
    ) {
        self.tags = tags
        self.color = color
        self.maxVisible = maxVisible
    }

    private var visibleTags: [String] {
        if let max = self.maxVisible, self.tags.count > max {
            return Array(self.tags.prefix(max))
        }
        return self.tags
    }

    private var hiddenCount: Int {
        if let maxCount = self.maxVisible {
            return Swift.max(0, self.tags.count - maxCount)
        }
        return 0
    }

    var body: some View {
        if self.tags.isEmpty {
            EmptyView()
        } else {
            FlowLayout(spacing: DesignTokens.Spacing.xxs) {
                ForEach(self.visibleTags, id: \.self) { tag in
                    TagChip(tag, color: self.color)
                }

                if self.hiddenCount > 0 {
                    Text("+\(self.hiddenCount)")
                        .font(DesignTokens.Typography.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, DesignTokens.Spacing.xs)
                        .padding(.vertical, DesignTokens.Spacing.xxs)
                        .background {
                            Capsule()
                                .fill(Color(.systemGray5))
                        }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("TagInput Interactive") {
    struct PreviewWrapper: View {
        @State
        private var tags: [String] = ["vegetarian", "quick"]

        let suggestions = [
            "breakfast", "lunch", "dinner",
            "vegetarian", "vegan", "gluten-free",
            "quick", "healthy", "comfort food",
            "favorite", "tested", "to-try"
        ]

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
                    // Default style
                    VStack(alignment: .leading) {
                        Text("Default Style")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(.secondary)

                        TagInput(tags: $tags, suggestions: suggestions)
                    }

                    Divider()

                    // With max tags (Exercise 2)
                    VStack(alignment: .leading) {
                        Text("With Max Tags (5)")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(.secondary)

                        TagInput(
                            tags: $tags,
                            suggestions: suggestions,
                            maxTags: 5
                        )
                    }
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}

#Preview("TagDisplay") {
    VStack(spacing: DesignTokens.Spacing.lg) {
        // Few tags
        TagDisplay(["vegetarian", "quick"])

        // Many tags with limit
        TagDisplay(
            ["breakfast", "vegetarian", "quick", "healthy", "favorite", "tested"],
            maxVisible: 3
        )

        // Different colors
        TagDisplay(["category"], color: .purple)
    }
    .padding()
}
