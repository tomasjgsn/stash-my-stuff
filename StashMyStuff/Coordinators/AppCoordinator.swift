import Observation
import SwiftUI

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
        self.navigationPath.append(destination)
    }

    func pop() {
        guard !self.navigationPath.isEmpty else { return }
        self.navigationPath.removeLast()
    }

    func popToRoot() {
        self.navigationPath = NavigationPath()
    }
}
