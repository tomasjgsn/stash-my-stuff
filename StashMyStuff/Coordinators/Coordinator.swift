import SwiftUI

protocol Coordinator: AnyObject {
    associatedtype ContentView: View

    @MainActor
    @ViewBuilder
    func start() -> ContentView
}
