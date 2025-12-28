//
//  AnimationPresets.swift
//  StashMyStuff
//

import SwiftUI

// MARK: - Animation Presets

extension Animation {
    /// Quick response for button presses, toggles
    static let quick = Animation.spring(response: 0.2, dampingFraction: 0.7)

    /// Standard interaction animation
    static let standard = Animation.spring(response: 0.3, dampingFraction: 0.7)

    /// Bouncy animation for celebratory moments
    static let appBouncy = Animation.spring(response: 0.4, dampingFraction: 0.5)

    /// Smooth animation for subtle changes
    static let appSmooth = Animation.spring(response: 0.4, dampingFraction: 1.0)

    /// Slow reveal for larger transitions
    static let reveal = Animation.spring(response: 0.5, dampingFraction: 0.8)
}

// MARK: - Transition Presets

extension AnyTransition {
    /// Slide in from bottom with fade
    static var slideUp: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }

    /// Scale in from center
    static var pop: AnyTransition {
        .scale(scale: 0.8).combined(with: .opacity)
    }

    /// Slide from trailing edge
    static var slideIn: AnyTransition {
        .move(edge: .trailing).combined(with: .opacity)
    }

    /// Card appear animation
    static var cardAppear: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.9)
                .combined(with: .opacity)
                .combined(with: .offset(y: 20)),
            removal: .scale(scale: 0.9)
                .combined(with: .opacity)
        )
    }
}

// MARK: - View Extensions

extension View {
    /// Applies a press effect that scales down when pressed
    func pressEffect(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.quick, value: isPressed)
    }

    /// Adds a shake animation (for errors)
    func shake(trigger: Bool) -> some View {
        self.modifier(ShakeModifier(trigger: trigger))
    }

    /// Adds a pulse animation
    func pulse(isActive: Bool) -> some View {
        self.modifier(PulseModifier(isActive: isActive))
    }

    /// Standard animation for list item operations
    func listItemAnimation() -> some View {
        self
            .transition(.asymmetric(
                insertion: .scale(scale: 0.9).combined(with: .opacity),
                removal: .scale(scale: 0.9).combined(with: .opacity)
            ))
    }
}

// MARK: - Shake Modifier

struct ShakeModifier: ViewModifier {
    let trigger: Bool
    @State
    private var shakeOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: self.shakeOffset)
            .onChange(of: self.trigger) { _, newValue in
                if newValue {
                    withAnimation(.linear(duration: 0.05)) {
                        self.shakeOffset = 10
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.linear(duration: 0.05)) {
                            self.shakeOffset = -10
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.linear(duration: 0.05)) {
                            self.shakeOffset = 5
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.linear(duration: 0.05)) {
                            self.shakeOffset = 0
                        }
                    }
                }
            }
    }
}

// MARK: - Pulse Modifier

struct PulseModifier: ViewModifier {
    let isActive: Bool
    @State
    private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(self.isPulsing ? 1.05 : 1.0)
            .opacity(self.isPulsing ? 0.8 : 1.0)
            .onAppear {
                guard self.isActive else { return }
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    self.isPulsing = true
                }
            }
            .onChange(of: self.isActive) { _, newValue in
                if newValue {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                        self.isPulsing = true
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.isPulsing = false
                    }
                }
            }
    }
}

// MARK: - Loading Indicator

/// A reusable loading indicator with animated dots
struct LoadingIndicator: View {
    let message: String?
    @State
    private var isAnimating = false

    init(_ message: String? = nil) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Animated dots
            HStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(0 ..< 3, id: \.self) { index in
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 10, height: 10)
                        .scaleEffect(self.isAnimating ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever()
                                .delay(Double(index) * 0.2),
                            value: self.isAnimating
                        )
                }
            }

            if let message {
                Text(message)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            self.isAnimating = true
        }
    }
}

// MARK: - Success Checkmark

/// An animated success checkmark
struct SuccessCheckmark: View {
    @State
    private var isVisible = false
    @State
    private var checkmarkScale: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(.green)
                .frame(width: 60, height: 60)
                .scaleEffect(self.isVisible ? 1.0 : 0.0)

            Image(systemName: "checkmark")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
                .scaleEffect(self.checkmarkScale)
        }
        .onAppear {
            // Circle appears
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                self.isVisible = true
            }

            // Checkmark bounces in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.1)) {
                self.checkmarkScale = 1.0
            }
        }
    }
}

// MARK: - Animated Heart Button (Exercise 1)

/// An animated heart that bursts into particles when favoriting
struct AnimatedHeartButton: View {
    @Binding
    var isFavorite: Bool
    @State
    private var particles: [HeartParticle] = []
    @State
    private var heartScale: CGFloat = 1.0

    var body: some View {
        Button {
            self.toggleFavorite()
        } label: {
            ZStack {
                // Particles
                ForEach(self.particles) { particle in
                    Circle()
                        .fill(Color.red.opacity(particle.opacity))
                        .frame(width: particle.size, height: particle.size)
                        .offset(x: particle.offset.width, y: particle.offset.height)
                }

                // Heart
                Image(systemName: self.isFavorite ? "heart.fill" : "heart")
                    .font(.title)
                    .foregroundStyle(self.isFavorite ? .red : .secondary)
                    .scaleEffect(self.heartScale)
            }
        }
        .buttonStyle(.plain)
    }

    private func toggleFavorite() {
        if !self.isFavorite {
            // Create particles
            self.particles = (0 ..< 8).map { _ in HeartParticle() }

            // Animate particles outward
            withAnimation(.easeOut(duration: 0.5)) {
                for i in self.particles.indices {
                    self.particles[i].offset = CGSize(
                        width: CGFloat.random(in: -30 ... 30),
                        height: CGFloat.random(in: -30 ... 30)
                    )
                    self.particles[i].opacity = 0
                }
            }

            // Heart bounce
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                self.heartScale = 1.3
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    self.heartScale = 1.0
                }
            }

            // Clear particles after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.particles = []
            }
        }

        self.isFavorite.toggle()
    }
}

struct HeartParticle: Identifiable {
    let id = UUID()
    var offset: CGSize = .zero
    var size = CGFloat.random(in: 4 ... 8)
    var opacity = 1.0
}

// MARK: - Category Picker (Exercise 2)

/// A picker where the selected category smoothly scales up
struct CategoryPicker: View {
    @Binding
    var selected: Category

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(Category.allCases, id: \.self) { category in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        self.selected = category
                    }
                } label: {
                    CategoryIcon(
                        category,
                        size: .medium,
                        style: self.selected == category ? .filled : .circle
                    )
                    .scaleEffect(self.selected == category ? 1.2 : 0.9)
                    .opacity(self.selected == category ? 1.0 : 0.6)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Previews

#Preview("Animation Presets") {
    struct PreviewWrapper: View {
        @State
        private var isToggled = false
        @State
        private var showError = false

        var body: some View {
            VStack(spacing: DesignTokens.Spacing.xl) {
                // Spring animations comparison
                HStack(spacing: DesignTokens.Spacing.lg) {
                    VStack {
                        Circle()
                            .fill(.blue)
                            .frame(width: 50, height: 50)
                            .scaleEffect(isToggled ? 1.3 : 1.0)
                            .animation(.quick, value: isToggled)
                        Text("Quick")
                            .font(.caption)
                    }

                    VStack {
                        Circle()
                            .fill(.green)
                            .frame(width: 50, height: 50)
                            .scaleEffect(isToggled ? 1.3 : 1.0)
                            .animation(.appBouncy, value: isToggled)
                        Text("Bouncy")
                            .font(.caption)
                    }

                    VStack {
                        Circle()
                            .fill(.purple)
                            .frame(width: 50, height: 50)
                            .scaleEffect(isToggled ? 1.3 : 1.0)
                            .animation(.appSmooth, value: isToggled)
                        Text("Smooth")
                            .font(.caption)
                    }
                }

                Button("Toggle") {
                    isToggled.toggle()
                }
                .buttonStyle(.primary)

                Divider()

                // Shake effect
                Text("Shake Me!")
                    .font(.headline)
                    .padding()
                    .background(Color.red.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shake(trigger: showError)

                Button("Trigger Shake") {
                    showError.toggle()
                }

                Divider()

                // Pulse effect
                Circle()
                    .fill(.orange)
                    .frame(width: 60, height: 60)
                    .pulse(isActive: isToggled)

                Text("Toggle to pulse")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("LoadingIndicator") {
    VStack(spacing: DesignTokens.Spacing.xl) {
        LoadingIndicator()
        LoadingIndicator("Saving...")
        LoadingIndicator("Syncing with iCloud")
    }
}

#Preview("SuccessCheckmark") {
    SuccessCheckmark()
}

#Preview("Animated Heart") {
    struct PreviewWrapper: View {
        @State
        private var isFavorite = false

        var body: some View {
            VStack(spacing: DesignTokens.Spacing.lg) {
                AnimatedHeartButton(isFavorite: $isFavorite)

                Text(isFavorite ? "Favorited!" : "Tap to favorite")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Category Picker") {
    struct PreviewWrapper: View {
        @State
        private var selected: Category = .recipe

        var body: some View {
            VStack(spacing: DesignTokens.Spacing.lg) {
                CategoryPicker(selected: $selected)

                Text("Selected: \(selected.rawValue)")
                    .font(DesignTokens.Typography.headline)
            }
            .padding()
        }
    }

    return PreviewWrapper()
}
