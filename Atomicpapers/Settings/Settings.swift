import SwiftUI
import MailCover

struct Settings: View {
    @EnvironmentObject private var userSettings: UserSettings
    
    @State private var presentMailCover = false
    
    var body: some View {
        List {
            Toggle("Download compressed images", isOn: $userSettings.downloadCompressedImages)
            
            Button("Suggest new wallpapers") {
                presentMailCover = true
            }
        }
        .mailCover(isPresented: $presentMailCover, message: "Take a look on these images!\n", subject: "New pictures for Atomicpapers", recipients: ["sergei_saliukov@icloud.com"], ccRecipients: ["example@mail.com"], bccRecipients: ["example@mail.ru"], alerts: .disabled)
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
            .environmentObject(UserSettings())
    }
}
