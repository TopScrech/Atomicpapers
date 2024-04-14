import ScrechKit
import WaterfallGrid

struct WaterfallList: View {
    @EnvironmentObject private var vm: RootVM
    
    private let images: [AtomicPaper]
    
    init(_ images: [AtomicPaper]) {
        self.images = images
    }
    
    @State private var isRedacted: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            Filter()
                .environmentObject(vm)
                .padding(.bottom, 5)
            
            ScrollView(showsIndicators: false) {
                WaterfallGrid(images, id: \.self) { image in
                    WaterfallImage(image, onUpdate: updateStats)
                }
                .gridStyle(columnsInLandscape: 3, spacing: 0, animation: .easeOut(duration: 1))
                
                WaterfallFooter(vm.filteredImages.count, isRedacted: isRedacted)
            }
        }
        .task { await vm.loadImages() }
        .onAppear {
            delay(3) {
                isRedacted = false
            }
        }
    }
    
    private func updateStats(_ image: AtomicPaper, update: whatToUpdate = .views) {
        Task {
            do {
                try await vm.updateRecord(image, update: update)
            } catch {
                print(error)
            }
        }
    }
}

struct AtomicList_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .darkSchemePreferred()
        
        RootView()
    }
}
