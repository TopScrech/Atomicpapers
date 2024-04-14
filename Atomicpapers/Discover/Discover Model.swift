import Foundation

struct DiscoverCardType: Identifiable {
    let id = UUID()
    let icon, name, urlString: String
    
    init(_ icon: String, name: String, urlString: String) {
        self.icon = icon
        self.name = name
        self.urlString = urlString
    }
}

func stringToUrl(_ link: String) -> URL {
    guard let url = URL(string: link) else {
        return URL(string: "https://topscrech.dev/invalidurl") ?? URL(fileURLWithPath: "")
    }
    return url
}
