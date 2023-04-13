import SwiftUI
import ScrechKit
import Kingfisher

struct AtomicImage: View {
    @StateObject private var imageLoader = ImageLoader()
    @EnvironmentObject private var navState: NavState
    @EnvironmentObject private var vm: RootVM
    @EnvironmentObject private var userSettings: UserSettings
    
    @State var image: AtomicPaper
    let onUpdate: (AtomicPaper, whatToUpdate) -> Void
    
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
                    .onSuccess { imageResult in
                        KingfisherManager.shared.cache.store(
                            imageResult.image,
                            forKey: image.name
                        )
                        cachedImage = imageResult.image
                    }
                    .placeholder { ProgressView() }
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
                    .padding(.bottom, vm.hideStats ? 8 : 0)
                    .onAppear {
                        delay(1) { vm.hideStats = false }
                    }
            }
            if !vm.hideStats {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack(spacing: 2) {
                                Text("\(image.downloads)")
                                Image(systemName: "square.and.arrow.down")
                            }
                            HStack(spacing: 2) {
                                Text("\(image.views)")
                                Image(systemName: "eye")
                            }
                        }
                        .foregroundColor(.white)
                        .padding(4)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.5)))
                        .footnote()
                        
                        Spacer()
                        
                        Menu {
                            VStack {
                                Text("Size" + ": \(imageLoader.size)\n" + "Resolution" + ": \(Int(imageLoader.dimensions.width)) x \(Int(imageLoader.dimensions.height))"
                                    .replacingOccurrences(of: ",", with: "")
                                )
                                .task {
                                    if userSettings.downloadCompressedImages {
                                        imageLoader.loadImage(from: getUrl(image.name + "eco", false))
                                    } else {
                                        imageLoader.loadImage(from: getUrl(image.name, false))
                                    }
                                }
                            }
                            
                            Divider()
                            
                            ShareLink(item: getUrl(image.name)) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            
                            Button {
                                if let inputImage = imageLoader.image {
                                    let imageSaver = ImageSaver()
                                    imageSaver.writeToPhotoAlbum(image: inputImage)
                                    var imageToUpdate = image
                                    imageToUpdate.downloads += 1
                                    image.downloads += 1
                                    onUpdate(imageToUpdate, .downloads)
                                }
                            } label: {
                                Label("Download", systemImage: "square.and.arrow.down")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .title()
                                .foregroundColor(.white)
                                .padding(3)
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                    }
                    .padding(.horizontal, 8)
                    .offset(y: -52)
                }
                .padding(.bottom, -40)
            }
        }
        .task {
            loadImageFromCache()
        }
    }
    
    private func loadImageFromCache() {
        KingfisherManager.shared.cache.retrieveImage(forKey: image.name) { result in
            switch result {
            case .success(let imageResult):
                main {
                    self.cachedImage = imageResult.image
                }
                
            case .failure:
                break
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
