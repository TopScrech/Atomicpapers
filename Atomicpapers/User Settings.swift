import SwiftUI

class UserSettings: ObservableObject {
    @AppStorage("downloadCompressedVersions") var downloadCompressedImages: Bool = false
}
