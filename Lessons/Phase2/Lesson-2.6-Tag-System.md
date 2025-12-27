# Lesson 2.6: Building the Tag System

> **Type**: Deep Dive (40-50 min)
> **Concepts**: NEW - @FocusState, TextField styling, Autocomplete, Flow layouts
> **Builds**: `DesignSystem/Components/TagChip.swift`, `DesignSystem/Components/TagInput.swift`

---

## What You'll Learn

Tags are a core feature of Stash My Stuff - they let users organize items across categories. In this deep dive, you'll build a complete tag system including display chips, input with autocomplete, and the flow layout to arrange them.

---

## Prerequisites

Complete **Lessons 2.1-2.5** - you'll use tokens, modifiers, and button styles.

---

## Part 1: The TagChip Component

Let's start with the simple display component:

**File**: `StashMyStuff/DesignSystem/Components/TagChip.swift`

```swift
//
//  TagChip.swift
//  StashMyStuff
//

import SwiftUI

/// A pill-shaped chip displaying a tag name
struct TagChip: View {
    let name: String
    let color: Color
    let onRemove: (() -> Void)?

    init(
        _ name: String,
        color: Color = .accentColor,
        onRemove: (() -> Void)? = nil
    ) {
        self.name = name
        self.color = color
        self.onRemove = onRemove
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xxs) {
            Text(name)
                .font(DesignTokens.Typography.caption)
                .fontWeight(.medium)

            if let onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xxs)
        .foregroundStyle(color)
        .background {
            Capsule()
                .fill(color.opacity(0.15))
        }
        .overlay {
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - Preview
#Preview("TagChip") {
    VStack(spacing: DesignTokens.Spacing.lg) {
        // Basic chips
        HStack {
            TagChip("vegetarian")
            TagChip("quick", color: .green)
            TagChip("favorite", color: .orange)
        }

        // With remove button
        HStack {
            TagChip("removable", onRemove: { })
            TagChip("another", color: .purple, onRemove: { })
        }

        // Different colors
        HStack {
            ForEach(Category.allCases.prefix(5), id: \.self) { category in
                TagChip(category.rawValue, color: category.color)
            }
        }
    }
    .padding()
}
```

---

## Part 2: Understanding @FocusState

Before building the tag input, let's understand focus management:

### NEW: @FocusState

`@FocusState` is a property wrapper that tracks and controls keyboard focus:

```swift
struct FocusExample: View {
    @FocusState private var isInputFocused: Bool
    @State private var text = ""

    var body: some View {
        VStack {
            TextField("Enter text", text: $text)
                .focused($isInputFocused)  // Bind focus state

            Button("Focus Input") {
                isInputFocused = true  // Programmatically focus
            }

            Button("Dismiss Keyboard") {
                isInputFocused = false  // Programmatically unfocus
            }
        }
    }
}
```

### Multiple Focus Fields

For forms with multiple fields, use an enum:

```swift
struct FormExample: View {
    enum Field {
        case title, description, notes
    }

    @FocusState private var focusedField: Field?
    @State private var title = ""
    @State private var description = ""

    var body: some View {
        Form {
            TextField("Title", text: $title)
                .focused($focusedField, equals: .title)

            TextField("Description", text: $description)
                .focused($focusedField, equals: .description)
        }
        .onSubmit {
            // Move to next field
            switch focusedField {
            case .title: focusedField = .description
            case .description: focusedField = .notes
            default: focusedField = nil
            }
        }
    }
}
```

---

## Part 3: Basic TagInput Component

Now let's build the tag input field:

**File**: `StashMyStuff/DesignSystem/Components/TagInput.swift`

```swift
//
//  TagInput.swift
//  StashMyStuff
//

import SwiftUI

/// An input field for adding tags with autocomplete suggestions
struct TagInput: View {
    @Binding var tags: [String]
    let suggestions: [String]
    let placeholder: String

    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool
    @State private var showSuggestions = false

    init(
        tags: Binding<[String]>,
        suggestions: [String] = [],
        placeholder: String = "Add tag..."
    ) {
        self._tags = tags
        self.suggestions = suggestions
        self.placeholder = placeholder
    }

    // Filter suggestions based on input
    private var filteredSuggestions: [String] {
        guard !inputText.isEmpty else { return [] }
        let lowercasedInput = inputText.lowercased()
        return suggestions
            .filter { suggestion in
                suggestion.lowercased().contains(lowercasedInput) &&
                !tags.contains(suggestion)
            }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            // Current tags
            if !tags.isEmpty {
                FlowLayout(spacing: DesignTokens.Spacing.xs) {
                    ForEach(tags, id: \.self) { tag in
                        TagChip(tag) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                tags.removeAll { $0 == tag }
                            }
                        }
                    }
                }
            }

            // Input field
            HStack(spacing: DesignTokens.Spacing.xs) {
                Image(systemName: "tag")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                TextField(placeholder, text: $inputText)
                    .font(DesignTokens.Typography.body)
                    .focused($isInputFocused)
                    .onSubmit {
                        addTag()
                    }
                    .onChange(of: inputText) { _, newValue in
                        showSuggestions = !newValue.isEmpty
                    }

                if !inputText.isEmpty {
                    Button {
                        inputText = ""
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

            // Suggestions dropdown
            if showSuggestions && !filteredSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(filteredSuggestions, id: \.self) { suggestion in
                        Button {
                            selectSuggestion(suggestion)
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

                        if suggestion != filteredSuggestions.last {
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
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else {
            inputText = ""
            return
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            tags.append(trimmed)
        }
        inputText = ""
        showSuggestions = false
    }

    private func selectSuggestion(_ suggestion: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            tags.append(suggestion)
        }
        inputText = ""
        showSuggestions = false
        isInputFocused = true  // Keep focus for adding more
    }
}
```

---

## Part 4: The FlowLayout

We need a proper flow layout for tags. Here's a robust implementation:

Add this to `TagInput.swift` or create a separate file:

```swift
// MARK: - Flow Layout
/// A layout that arranges views in rows, wrapping to new lines as needed
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var alignment: HorizontalAlignment = .leading

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)

        for (index, position) in result.positions.enumerated() {
            let adjustedX: CGFloat
            switch alignment {
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
                rowWidths.append(currentRowWidth - spacing)
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
                currentRowWidth = 0
                currentRowIndex += 1
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            rowIndices.append(currentRowIndex)
            currentX += size.width + spacing
            currentRowWidth = currentX
            lineHeight = max(lineHeight, size.height)
        }

        // Add last row width
        if currentRowWidth > 0 {
            rowWidths.append(currentRowWidth - spacing)
        }

        let totalSize = CGSize(
            width: maxWidth,
            height: currentY + lineHeight
        )

        return (totalSize, positions, rowWidths, rowIndices)
    }
}
```

---

## Part 5: Enhanced TagInput with Styles

Let's add different visual styles:

```swift
// MARK: - Tag Input Styles
extension TagInput {
    enum Style {
        case `default`
        case outlined
        case glass
    }
}

// Create styled variant
struct StyledTagInput: View {
    @Binding var tags: [String]
    let suggestions: [String]
    let placeholder: String
    let style: TagInput.Style

    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    init(
        tags: Binding<[String]>,
        suggestions: [String] = [],
        placeholder: String = "Add tag...",
        style: TagInput.Style = .default
    ) {
        self._tags = tags
        self.suggestions = suggestions
        self.placeholder = placeholder
        self.style = style
    }

    private var filteredSuggestions: [String] {
        guard !inputText.isEmpty else { return [] }
        return suggestions
            .filter { $0.lowercased().contains(inputText.lowercased()) && !tags.contains($0) }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            // Tags and input in one container
            containerView {
                FlowLayout(spacing: DesignTokens.Spacing.xs) {
                    // Existing tags
                    ForEach(tags, id: \.self) { tag in
                        TagChip(tag) {
                            withAnimation {
                                tags.removeAll { $0 == tag }
                            }
                        }
                    }

                    // Inline input
                    inlineInput
                }
            }

            // Suggestions
            if !filteredSuggestions.isEmpty && isInputFocused {
                suggestionsView
            }
        }
    }

    @ViewBuilder
    private func containerView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        switch style {
        case .default:
            content()
                .padding(DesignTokens.Spacing.sm)
                .background {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                        .fill(Color(.systemGray6))
                }

        case .outlined:
            content()
                .padding(DesignTokens.Spacing.sm)
                .background {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                }

        case .glass:
            content()
                .padding(DesignTokens.Spacing.sm)
                .glassBackground(cornerRadius: DesignTokens.Radius.md)
        }
    }

    private var inlineInput: some View {
        TextField(tags.isEmpty ? placeholder : "Add more...", text: $inputText)
            .font(DesignTokens.Typography.body)
            .focused($isInputFocused)
            .frame(minWidth: 100)
            .onSubmit {
                addCurrentTag()
            }
    }

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(filteredSuggestions, id: \.self) { suggestion in
                Button {
                    selectSuggestion(suggestion)
                } label: {
                    Text(suggestion)
                        .font(DesignTokens.Typography.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                .fill(Color(.secondarySystemBackground))
                .shadow(DesignTokens.Shadows.sm)
        }
    }

    private func addCurrentTag() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else {
            inputText = ""
            return
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            tags.append(trimmed)
        }
        inputText = ""
    }

    private func selectSuggestion(_ suggestion: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            tags.append(suggestion)
        }
        inputText = ""
        isInputFocused = true
    }
}
```

---

## Part 6: Read-Only Tag Display

For showing tags without editing:

```swift
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
        if let max = maxVisible, tags.count > max {
            return Array(tags.prefix(max))
        }
        return tags
    }

    private var hiddenCount: Int {
        if let max = maxVisible {
            return max(0, tags.count - max)
        }
        return 0
    }

    var body: some View {
        if tags.isEmpty {
            EmptyView()
        } else {
            FlowLayout(spacing: DesignTokens.Spacing.xxs) {
                ForEach(visibleTags, id: \.self) { tag in
                    TagChip(tag, color: color)
                }

                if hiddenCount > 0 {
                    Text("+\(hiddenCount)")
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
```

---

## Part 7: Complete Preview Suite

```swift
// MARK: - Previews
#Preview("TagInput Interactive") {
    struct PreviewWrapper: View {
        @State private var tags: [String] = ["vegetarian", "quick"]

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

                    // Outlined style
                    VStack(alignment: .leading) {
                        Text("Outlined Style")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(.secondary)

                        StyledTagInput(
                            tags: $tags,
                            suggestions: suggestions,
                            style: .outlined
                        )
                    }

                    // Glass style (on gradient)
                    ZStack {
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))

                        VStack(alignment: .leading) {
                            Text("Glass Style")
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(.secondary)

                            StyledTagInput(
                                tags: $tags,
                                suggestions: suggestions,
                                style: .glass
                            )
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}
```

---

## Part 8: Integration with StashItem

Here's how to use the tag system with your actual models:

```swift
// MARK: - Item Tags Editor
/// A complete tag editor bound to a StashItem
struct ItemTagsEditor: View {
    @Bindable var item: StashItem
    let allTags: [Tag]  // Fetched from repository

    @State private var tagNames: [String] = []

    var suggestions: [String] {
        allTags
            .map(\.name)
            .filter { !tagNames.contains($0) }
    }

    var body: some View {
        TagInput(
            tags: $tagNames,
            suggestions: suggestions,
            placeholder: "Add tags..."
        )
        .onAppear {
            tagNames = item.tags.map(\.name)
        }
        .onChange(of: tagNames) { _, newTags in
            // Sync back to model
            // This would need proper tag lookup/creation logic
            // item.tags = ... (handled in ViewModel)
        }
    }
}
```

---

## Exercise: Your Turn

### Exercise 1: Colored Tag Chips

Modify `TagChip` to support automatic color assignment based on tag name (hash the string to pick from a palette):

<details>
<summary>Solution</summary>

```swift
extension TagChip {
    init(autoColored name: String, onRemove: (() -> Void)? = nil) {
        let colors: [Color] = [.blue, .purple, .pink, .orange, .green, .teal, .indigo]
        let index = abs(name.hashValue) % colors.count
        self.init(name, color: colors[index], onRemove: onRemove)
    }
}

// Usage
TagChip(autoColored: "vegetarian")
```

</details>

### Exercise 2: Tag Limit

Add a `maxTags` parameter to `TagInput` that disables input when the limit is reached:

<details>
<summary>Hint</summary>

Disable the TextField and show a message when `tags.count >= maxTags`.

</details>

---

## What You Built

A complete tag system in `DesignSystem/Components/`:

**TagChip.swift:**
- `TagChip` - Styled tag pill with optional remove button

**TagInput.swift:**
- `TagInput` - Input field with autocomplete
- `StyledTagInput` - Multiple visual styles
- `TagDisplay` - Read-only tag display
- `FlowLayout` - Reusable wrapping layout

---

## Key Concepts Learned

| Concept | What You Learned |
|---------|------------------|
| `@FocusState` | Managing keyboard focus programmatically |
| `Layout` protocol | Custom layout algorithms |
| Autocomplete | Filtering and displaying suggestions |
| Binding arrays | Two-way binding with collections |
| Animation coordination | Smooth add/remove animations |

---

## File Structure Update

```
StashMyStuff/
└── DesignSystem/
    ├── DesignTokens.swift
    ├── Modifiers/
    │   ├── GlassModifier.swift
    │   ├── CategoryModifier.swift
    │   └── ConditionalModifiers.swift
    ├── Styles/
    │   └── ButtonStyles.swift
    └── Components/
        ├── GlassCard.swift
        ├── CategoryIcon.swift
        ├── FlagButton.swift
        ├── TagChip.swift          ← New
        └── TagInput.swift         ← New
```

---

## Next Lesson

In **Lesson 2.7: List Row Components**, you'll build the `StashItemRow` and `CategoryCard` components that display items and categories in lists and grids.

---

## Questions for Claude

When working through this lesson, you can ask:
- "How do I dismiss the keyboard when tapping outside?"
- "Can you explain the Layout protocol in more detail?"
- "How would I save new tags to SwiftData?"
- "How do I make the suggestions appear as an overlay?"

Reference this lesson as: **"Lesson 2.6 - Tag System"**
