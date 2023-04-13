import SwiftUI

enum NavDestinations: Hashable {
    case toImageView(_ image: AtomicPaper)
}

class NavState: ObservableObject {
    @Published var path = NavigationPath()
    
    func navigate(to navDestination: NavDestinations) {
        path.append(navDestination)
    }
    
    func dismiss() { path.removeLast() }
}

extension View {
    func withNavDestinations() -> some View {
        self.navigationDestination(for: NavDestinations.self) { destination in
            switch destination {
            case .toImageView(let image): ImageView(image)
            }
        }
    }
}
