import ScrechKit
import Kingfisher

struct WaterfallImage: View {
    @StateObject private var imageLoader = ImageLoader()
    @EnvironmentObject private var navState: NavState
    @EnvironmentObject private var vm: RootVM
    @EnvironmentObject private var userSettings: UserSettings
    
    @State private var image: AtomicPaper
    
    private let onUpdate: (AtomicPaper, whatToUpdate) -> Void
    
    init(_ image: AtomicPaper, onUpdate: @escaping (AtomicPaper, whatToUpdate) -> Void) {
        self.image = image
        self.onUpdate = onUpdate
    }
    
    @State private var cachedImage: UIImage?
    
    var body: some View {
        VStack {
            Button {
                navState.navigate(to: .toImageView(image))
                
                var imageToUpdate = image
                imageToUpdate.views += 1
                
                image.views += 1
                onUpdate(imageToUpdate, .views)
            } label: {
                KFImage(getUrl(image.name))
                    .fade(duration: 0.25)
                    .placeholder {
                        ProgressView()
                    }
                    .onSuccess { result in
                        KingfisherManager.shared.cache.store(result.image, forKey: image.name)
                        cachedImage = result.image
                    }
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .scaledToFit()
                    .overlay {
                        Group {
                            if vm.hideStats {
                                EmptyView()
                            } else {
                                RoundedRectangle(cornerRadius: 16).stroke(Color("retheme"), lineWidth: 3)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
            }
            if !vm.hideStats {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Label(String(image.downloads), systemImage: "square.and.arrow.down")
                            Label(String(image.views), systemImage: "eye")
                        }
                        .foregroundColor(.white)
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.5)))
                        .footnote()
                        
                        Spacer()
                        
                        Menu {
                            VStack {
#if DEBUG
                                Text(image.name)
#endif
                                Text("Size" + ": \(imageLoader.size)")
                                
                                Text("Resolution" + ": \(Int(imageLoader.dimensions.width)) x \(Int(imageLoader.dimensions.height))"
                                    .replacingOccurrences(of: ",", with: "")
                                )
                                .task {
                                    imageLoader.loadImage(getUrl(userSettings.downloadCompressedImages ? "\(image.name)eco" : image.name, false))
                                }
                            }
                            
                            Section {
                                ShareLink(item: getUrl(image.name)) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                
                                Button {
                                    if let inputImage = imageLoader.image {
                                        let imageSaver = ImageSaver()
                                        imageSaver.writeToPhotoAlbum(inputImage)
                                        var imageToUpdate = image
                                        imageToUpdate.downloads += 1
                                        image.downloads += 1
                                        onUpdate(imageToUpdate, .downloads)
                                    }
                                } label: {
                                    Label("Download", systemImage: "square.and.arrow.down")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .title()
                                .foregroundColor(.white)
                                .padding(3)
#error("Conflict between ScrechKit and SwiftUI")
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                    }
                    .padding(.horizontal, 8)
                    .offset(y: -52)
                }
                .padding(.bottom, -40)
            }
        }
        .task { loadImageFromCache() }
        .onAppear {
            delay(1) {
                vm.hideStats = false
            }
        }
    }
    
    private func loadImageFromCache() {
        KingfisherManager.shared.cache.retrieveImage(forKey: image.name) { result in
            switch result {
            case .success(let result):
                main {
                    self.cachedImage = result.image
                }
                
            case .failure: break
            }
        }
    }
}

struct ListImage_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .darkSchemePreferred()
        
        RootView()
    }
}
