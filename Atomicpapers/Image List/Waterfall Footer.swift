import SwiftUI

struct WaterfallFooter: View {
    private let count: Int
    @State private var isRedacted: Bool
    
    init(_ count: Int = 0, isRedacted: Bool) {
        self.count = count
        self.isRedacted = isRedacted
    }
    
    @State private var showSafari: Bool = false
    
    var body: some View {
        VStack {
            Text("Total: \(count)")
                .redacted(isRedacted)
            
            Divider()
                .frame(width: 160)
            
            Button {
                showSafari = true
            } label: {
                VStack {
                    Text("Want more?")
                        .foregroundColor(Color("retheme"))
                    
                    Text("Continue in VK")
                }
            }
        }
        .safariCover($showSafari, url: "https://vk.com/atomicheart_game")
    }
}

struct Waterfall_Footer_Previews: PreviewProvider {
    static var previews: some View {
        WaterfallFooter(isRedacted: .random())
            .darkSchemePreferred()
        
        WaterfallFooter(isRedacted: .random())
    }
}
