//
//  HapticService.swift
//  StashMyStuff
//

import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

// MARK: - Haptic Service

/// Provides haptic feedback for user interactions
@MainActor
final class HapticService {
    static let shared = HapticService()

    private init() {}

    // MARK: - Impact Feedback

    /// Light impact - subtle feedback for small UI changes
    func lightImpact() {
        #if canImport(UIKit) && !os(macOS)
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        #endif
    }

    /// Medium impact - standard button presses, toggles
    func mediumImpact() {
        #if canImport(UIKit) && !os(macOS)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        #endif
    }

    /// Heavy impact - significant actions, confirmations
    func heavyImpact() {
        #if canImport(UIKit) && !os(macOS)
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        #endif
    }

    /// Soft impact - gentle, cushioned feel
    func softImpact() {
        #if canImport(UIKit) && !os(macOS)
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        #endif
    }

    /// Rigid impact - sharp, precise feel
    func rigidImpact() {
        #if canImport(UIKit) && !os(macOS)
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        #endif
    }

    // MARK: - Notification Feedback

    /// Success - task completed successfully
    func success() {
        #if canImport(UIKit) && !os(macOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        #endif
    }

    /// Warning - caution needed
    func warning() {
        #if canImport(UIKit) && !os(macOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        #endif
    }

    /// Error - something went wrong
    func error() {
        #if canImport(UIKit) && !os(macOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        #endif
    }

    // MARK: - Selection Feedback

    /// Selection changed - for pickers, toggles
    func selectionChanged() {
        #if canImport(UIKit) && !os(macOS)
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        #endif
    }

    // MARK: - Semantic Haptics (Convenience)

    /// Flag toggled on/off
    func flagToggled(isNowActive: Bool) {
        if isNowActive {
            self.mediumImpact()
        } else {
            self.lightImpact()
        }
    }

    /// Item saved successfully
    func itemSaved() {
        self.success()
    }

    /// Item deleted
    func itemDeleted() {
        self.rigidImpact()
    }

    /// Favorite toggled
    func favoriteToggled(isFavorite: Bool) {
        if isFavorite {
            // Double tap feeling for adding favorite
            self.lightImpact()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.lightImpact()
            }
        } else {
            self.lightImpact()
        }
    }

    /// Pull to refresh triggered
    func pullToRefresh() {
        self.mediumImpact()
    }

    /// Button pressed
    func buttonTapped() {
        self.lightImpact()
    }

    /// Category selected
    func categorySelected() {
        self.selectionChanged()
    }

    /// Error occurred
    func errorOccurred() {
        self.error()
    }
}

// MARK: - View Extension

extension View {
    /// Adds haptic feedback on tap
    func hapticOnTap(_ feedback: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded { _ in
                feedback()
            }
        )
    }

    /// Adds light haptic on tap
    func hapticLight() -> some View {
        self.hapticOnTap {
            HapticService.shared.lightImpact()
        }
    }

    /// Adds medium haptic on tap
    func hapticMedium() -> some View {
        self.hapticOnTap {
            HapticService.shared.mediumImpact()
        }
    }

    /// Adds selection haptic on tap
    func hapticSelection() -> some View {
        self.hapticOnTap {
            HapticService.shared.selectionChanged()
        }
    }
}

// MARK: - Preview

#Preview("Haptic Service Demo") {
    VStack(spacing: DesignTokens.Spacing.lg) {
        Text("Haptic Feedback Demo")
            .font(DesignTokens.Typography.title)

        Text("Run on a real device to feel haptics")
            .font(DesignTokens.Typography.caption)
            .foregroundStyle(.secondary)

        Divider()

        Group {
            Button("Light Impact") {
                HapticService.shared.lightImpact()
            }

            Button("Medium Impact") {
                HapticService.shared.mediumImpact()
            }

            Button("Heavy Impact") {
                HapticService.shared.heavyImpact()
            }

            Button("Soft Impact") {
                HapticService.shared.softImpact()
            }

            Button("Rigid Impact") {
                HapticService.shared.rigidImpact()
            }
        }
        .buttonStyle(.secondary)

        Divider()

        Group {
            Button("Success") {
                HapticService.shared.success()
            }
            .buttonStyle(.primary(color: .green))

            Button("Warning") {
                HapticService.shared.warning()
            }
            .buttonStyle(.primary(color: .orange))

            Button("Error") {
                HapticService.shared.error()
            }
            .buttonStyle(.primary(color: .red))
        }

        Divider()

        Button("Selection Changed") {
            HapticService.shared.selectionChanged()
        }
        .buttonStyle(.secondary)
    }
    .padding()
}
