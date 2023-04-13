import SwiftUI
import WaterfallGrid

struct WaterfallList: View {
    @EnvironmentObject private var vm: RootVM
    
    let images: [AtomicPaper]
    
    init(_ images: [AtomicPaper]) {
        self.images = images
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                WaterfallGrid(vm.filteredImages.indices, id: \.self) { index in
                    AtomicImage(vm.filteredImages[index], onUpdate: updateViews)
                }
                .padding(.top)
                .gridStyle(
                    columnsInPortrait: 2,
                    columnsInLandscape: 2,
                    spacing: 0,
                    animation: .easeOut(duration: 1)
                )
            }
        }
        .task {
            do {
                try await vm.populateImages()
            } catch {
                print("error228 \(error)")
            }
        }
    }
    
    private func updateViews(_ image: AtomicPaper, update: whatToUpdate = .views) {
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
