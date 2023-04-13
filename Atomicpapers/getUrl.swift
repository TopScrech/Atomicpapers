import Foundation

func getUrl(_ imageName: String, _ isEco: Bool = true) -> URL {
    guard let url: URL = URL(string: "https://topscrech.dev/atomicpapers/\(imageName)\(isEco ? "eco" : "").heic") else {
        return URL(string: "https://topscrech.dev")!
    }
    return url
}
