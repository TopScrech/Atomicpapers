import SwiftUI

struct Discover: View {
    let cards: [DiscoverCardType] = [
        .init(
            icon: "app.gift",
            name: "Other apps",
            urlString: "https://apps.apple.com/developer/sergei-saliukov/id1639409936"
        ),
        .init(
            icon: "app.connected.to.app.below.fill",
            name: "GitHub Projects",
            urlString: "https://topscrech.dev/wrfgwrg"
        )
    ]
    
    var body: some View {
        VStack {
            Text("Discover")
                .largeTitle()
                .bold()
                .padding(.top, 16)
                .padding(.bottom, -1)
            
            Divider()
            
            ScrollView {
                ForEach(cards) { card in
                    DiscoverCard(
                        icon: card.icon,
                        name: card.name,
                        urlString: card.urlString
                    )
                }
            }
            
            Spacer()
        }
    }
}

struct Discover_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            Discover()
                .sheet(isPresented: .constant(true)) {
                    Discover()
                        .presentationDetents([.large, .medium])
                }
        }
    }
}
