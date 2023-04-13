import SwiftUI

struct RootView: View {
    @StateObject private var vm = RootVM()
    
    @State private var sheetSettings: Bool = false
    
    var body: some View {
        WaterfallList(vm.images)
            .environmentObject(vm)
            .sheet(isPresented: $sheetSettings) { Settings() }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        sheetSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .semibold()
                    }
                }
            }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootContainer()
            .darkSchemePreferred()
        
        RootContainer()
            .previewDevice("iPhone SE (3rd generation)")
    }
}
