import Foundation

struct DiscoverCardType: Identifiable {
    let id = UUID()
    let icon, name, urlString: String
}

func stringToUrl(_ link: String) -> URL {
    guard let url = URL(string: link) else {
        return URL(string: "https://topscrech.dev/invalidurl") ?? URL(fileURLWithPath: "")
    }
    return url
}
