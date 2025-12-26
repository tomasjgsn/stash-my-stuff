import SwiftUI
import Observation

@Observable
final class AppCoordinator {
    var navigationPath = NavigationPath()

    enum Destination: Hashable {
        case category(CategoryDestination)
        case itemDetail(ItemDetailDestination)
        case settings
    }

    struct CategoryDestination: Hashable {
        let categoryId: String
    }

    struct ItemDetailDestination: Hashable {
        let itemId: String
    }

    func navigate(to destination: Destination) {
        navigationPath.append(destination)
    }

    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }

    func popToRoot() {
        navigationPath = NavigationPath()
    }
}
