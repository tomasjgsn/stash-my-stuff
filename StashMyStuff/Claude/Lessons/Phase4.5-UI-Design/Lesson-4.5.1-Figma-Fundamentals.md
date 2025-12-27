# Lesson 4.5.1: Figma Fundamentals

> **Type**: Standard lesson (45 min)
> **Concepts**: NEW - Figma interface, frames, components, auto layout
> **Builds**: Figma account, workspace setup, first components

---

## What You'll Learn

This lesson gets you comfortable with Figma's interface and core concepts. By the end, you'll have your workspace set up and understand how to create, organize, and reuse design elements.

---

## Part 1: Getting Started with Figma

### Create Your Account

1. Go to [figma.com](https://www.figma.com)
2. Sign up with email (or Google/etc.)
3. Choose **Starter** (free) plan
4. Complete the onboarding tour

### Understanding the Free Plan

You get:
- 3 Figma design files
- Unlimited drafts (personal only)
- Basic prototyping
- Export capabilities

We'll use our 3 files strategically:
1. **Design System** - All reusable components
2. **iOS Screens** - App screen designs
3. **Prototype** - Interactive flows

### Create Your First File

1. Click **+ New design file**
2. Name it: "Stash My Stuff - Design System"
3. This is File 1 of 3 - use it wisely!

---

## Part 2: The Figma Interface

### Toolbar (Top)
```
┌─────────────────────────────────────────────────────────────────────┐
│ [Menu] [Move] [Frame] [Shape] [Pen] [Text] [Hand] [Comment] [▶ Play]│
└─────────────────────────────────────────────────────────────────────┘
```

Key tools:
- **Move (V)**: Select and move objects
- **Frame (F)**: Create containers (like divs in web)
- **Text (T)**: Add text
- **Hand (H)**: Pan around the canvas

### Left Panel - Layers
Shows the hierarchy of everything on your canvas:
```
📄 Page 1
  └── 📁 Frame 1
       ├── 📝 Text
       ├── ⬜ Rectangle
       └── 📁 Nested Frame
```

### Right Panel - Properties
Shows properties of selected element:
- Position & size
- Colors & effects
- Typography settings
- Auto layout options

### Canvas (Center)
Your infinite workspace. Zoom with scroll wheel or pinch.

---

## Part 3: Frames - The Foundation

### What is a Frame?

A frame is a container. Think of it like:
- A `VStack` or `HStack` in SwiftUI
- A `div` in web development
- A box that holds things

### Creating Frames

**Method 1**: Draw a frame
1. Press **F** for the frame tool
2. Click and drag to create
3. Set size in right panel

**Method 2**: Use device presets
1. Press **F** for frame tool
2. Look at right panel → "Phone" → "iPhone 16 Pro"
3. Click to create an iPhone-sized frame

### Frame vs Rectangle

| Frame | Rectangle |
|-------|-----------|
| Can contain children | Just a shape |
| Has auto layout | No auto layout |
| Use for UI containers | Use for decorative shapes |

---

## Part 4: Auto Layout - Automatic Spacing

### What is Auto Layout?

Auto Layout makes frames behave like SwiftUI stacks:
- Children arrange automatically
- Spacing is consistent
- Resizing is automatic

**SwiftUI parallel**:
```swift
// This VStack with spacing...
VStack(spacing: 16) {
    Text("Hello")
    Text("World")
}
.padding(20)

// Is like Auto Layout with:
// Direction: Vertical
// Gap: 16
// Padding: 20
```

### Adding Auto Layout

1. Select a frame
2. Press **Shift + A** (or click "+" next to Auto Layout in right panel)
3. Configure:
   - **Direction**: Horizontal or Vertical
   - **Gap**: Space between items
   - **Padding**: Space inside the frame

### Try It: Create a Button

1. Create a frame (F)
2. Add auto layout (Shift+A)
3. Add text inside: "Save Item"
4. Set padding: 16 horizontal, 12 vertical
5. Add background: Select frame → Fill → Blue
6. Add corner radius: 12

You just made a button!

---

## Part 5: Components - Reusable Elements

### What is a Component?

A component is a reusable element. Change the "main component" and all instances update.

**SwiftUI parallel**:
```swift
// Like creating a reusable View
struct PrimaryButton: View {
    let title: String
    var body: some View {
        Text(title)
            .padding()
            .background(.blue)
            .foregroundStyle(.white)
    }
}
```

### Creating a Component

1. Select your button frame
2. Press **Cmd + Option + K** (or right-click → Create Component)
3. The frame gets a purple diamond icon ◇

### Using Component Instances

1. Find your component in the left panel (or Assets panel)
2. Drag it onto the canvas
3. This creates an "instance" linked to the main component

### Editing Components

- **Edit main component**: Double-click any instance
- **Override in instance**: Select instance, change text/colors (won't affect others)
- **Reset overrides**: Right-click → Reset all changes

---

## Part 6: Organizing Your Design System

### Page Structure

Create multiple pages in your file:

```
📄 Cover (title page with file info)
📄 Colors
📄 Typography
📄 Icons
📄 Components
📄 Patterns (component combinations)
```

To create a page:
1. Click **+** next to "Page 1" in the left panel
2. Rename by double-clicking

### Frame Organization

On each page, organize with frames:

```
📄 Colors
  └── 📁 Frame: "Color Palette"
       ├── 📁 "Primary Colors"
       ├── 📁 "Category Colors"
       └── 📁 "Semantic Colors"
```

### Naming Conventions

Use clear, consistent names:
- Components: `Button / Primary / Default`
- Colors: `Color / Category / Recipe`
- Icons: `Icon / Category / Book`

The `/` creates folder-like grouping in the Assets panel.

---

## Part 7: Setting Up Our Design System File

### Step 1: Create Cover Page

1. On Page 1, rename to "Cover"
2. Create a frame (any size)
3. Add text:
   - "Stash My Stuff"
   - "Design System"
   - Your name
   - Date

### Step 2: Create Color Page

1. Create new page: "Colors"
2. Create a frame: "Category Colors"
3. Add 10 rectangles (60x60)
4. Apply these colors:
   - Recipe: `#FF9500` (Orange)
   - Book: `#5856D6` (Indigo)
   - Movie: `#AF52DE` (Purple)
   - Music: `#FF2D55` (Pink)
   - Clothes: `#30B0C7` (Teal)
   - Home: `#A2845E` (Brown)
   - Article: `#007AFF` (Blue)
   - Podcast: `#34C759` (Green)
   - Trip: `#32ADE6` (Cyan)
   - Backpack: `#8E8E93` (Gray)
5. Add labels below each

### Step 3: Create Typography Page

1. Create new page: "Typography"
2. Create text samples for each style:
   - Large Title: 34pt, Bold
   - Title: 28pt, Bold
   - Title 2: 22pt, Bold
   - Headline: 17pt, Semibold
   - Body: 17pt, Regular
   - Callout: 16pt, Regular
   - Caption: 12pt, Regular

### Step 4: Create Components Page

1. Create new page: "Components"
2. You'll populate this as you design

---

## Part 8: Keyboard Shortcuts

Essential shortcuts to memorize:

| Action | Shortcut |
|--------|----------|
| Move tool | V |
| Frame tool | F |
| Text tool | T |
| Pan/Hand | H (or hold Space) |
| Zoom | Scroll or Cmd + +/- |
| Zoom to selection | Shift + 1 |
| Zoom to fit | Shift + 0 |
| Create component | Cmd + Option + K |
| Auto Layout | Shift + A |
| Group | Cmd + G |
| Ungroup | Cmd + Shift + G |
| Duplicate | Cmd + D or Option + Drag |
| Copy style | Cmd + Option + C |
| Paste style | Cmd + Option + V |

---

## Checkpoint: Your First Component

Create a simple "Tag Chip" component:

1. Create a frame with Auto Layout (horizontal)
2. Add text: "vegetarian"
3. Set:
   - Padding: 8 horizontal, 4 vertical
   - Corner radius: 12 (full pill shape)
   - Background: Light blue (#E8F4FD)
   - Text color: Blue (#007AFF)
   - Font: 13pt, Medium
4. Convert to component (Cmd + Option + K)
5. Create 3 instances with different text

---

## Exercise: Create Category Card

Create a component for the home screen category cards:

Requirements:
- Auto Layout (vertical)
- Category icon (use a placeholder rectangle for now)
- Category name
- Item count ("12 items")
- Background color from the category
- Corner radius: 16

<details>
<summary>Hint</summary>

Structure:
```
Frame (auto layout vertical, center aligned)
├── Icon placeholder (44x44 circle)
├── Category name (headline style)
└── Item count (caption style, secondary color)
```

</details>

---

## What You Built

- Figma account with free plan
- Design System file with page structure
- Understanding of frames and auto layout
- First reusable components

---

## Key Concepts Learned

| Figma Concept | SwiftUI Equivalent |
|---------------|-------------------|
| Frame | VStack/HStack/ZStack |
| Auto Layout | Stack with spacing |
| Component | Reusable View struct |
| Instance | Using a View |
| Override | Passing different props |

---

## Common Mistakes to Avoid

1. **Not using Auto Layout**: Everything should use it
2. **Forgetting to create components**: If you'll use it twice, make it a component
3. **Messy layer names**: Rename everything clearly
4. **Using groups instead of frames**: Frames are more powerful

---

## Next Lesson

In **Lesson 4.5.2: Design System File**, you'll build out the complete component library including all buttons, cards, and list items.

---

## Questions for Claude

When working through this lesson, you can ask:
- "How do I align items in Auto Layout?"
- "What's the difference between 'Fill' and 'Hug' in Auto Layout?"
- "How do I create a component variant?"
- "Can you explain Figma's constraint system?"

Reference this lesson as: **"Lesson 4.5.1 - Figma Fundamentals"**
