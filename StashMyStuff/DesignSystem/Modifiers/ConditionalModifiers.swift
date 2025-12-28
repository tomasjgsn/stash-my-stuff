//
//  ConditionalModifiers.swift
//  StashMyStuff
//
//  Created by Tomas Juergensen on 27/12/2025.
//

import SwiftUI

extension View {
    /// Applies a modifier only when a condition is true
    /// Usage: Text("Hello").when(isHighlighted) { $0.bold() }
    @ViewBuilder
    func when(_ condition: Bool, apply transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies one modifier when true, another when false
    /// Usage: Text("Status").whenElse(isActive, then: { $0.foregroundStyle(.green) }, else: { $0.foregroundStyle(.gray)
    /// })
    @ViewBuilder
    func whenElse(
        _ condition: Bool,
        then trueTransform: (Self) -> some View,
        else falseTransform: (Self) -> some View
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }

    /// Applies a modifier if the optional has a value
    /// Usage: Text("Item").ifLet(item.imageURL) { view, url in view.overlay(AsyncImage(url: url)) }
    @ViewBuilder
    func ifLet<T>(_ optional: T?, transform: (Self, T) -> some View) -> some View {
        if let value = optional {
            transform(self, value)
        } else {
            self
        }
    }
}
