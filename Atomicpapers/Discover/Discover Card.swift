import SwiftUI

struct DiscoverCard: View {
    let icon, name, urlString: String
    
    init(_ icon: String, name: String, urlString: String) {
        self.icon = icon
        self.name = name
        self.urlString = urlString
    }
    
    @State private var presentQRCode: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
            
            Text(name)
                .font(.system(.title3, weight: .semibold))
            
            Spacer()
            
            Button {
                presentQRCode = true
            } label: {
                Image(systemName: "qrcode")
                    .font(.system(.title, weight: .bold))
                    .frame(width: 55, height: 55)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 20))
            }
            
            Menu {
                Button {
                    guard let url = URL(string: urlString) else { return }
                    UIApplication.shared.open(url)
                } label: {
                    Label("Open", systemImage: "link")
                }
                ShareLink("Share...", item: stringToUrl(urlString))
            } label: {
                Image(systemName: "link")
                    .font(.system(.title, weight: .bold))
                    .frame(width: 55, height: 55)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $presentQRCode) {
            DiscoverQR(urlString: urlString)
                .presentationDetents([.medium])
        }
    }
}

struct DiscoverCard_Previews: PreviewProvider {
    static var previews: some View {
        Discover()
    }
}
