import SwiftUI
import Kingfisher

struct ImageView: View {
    @StateObject private var imageLoader = ImageLoader()
    
    @State var image: AtomicPaper
    
    init(_ image: AtomicPaper) {
        self.image = image
    }
    
    @State private var cachedImage: UIImage?
    
    var body: some View {
        ZStack {
            VStack {
                KFImage(getUrl(image.name, false))
                    .fade(duration: 0.25)
                    .onSuccess { imageResult in
                        KingfisherManager.shared.cache.store(
                            imageResult.image,
                            forKey: image.name
                        )
                        cachedImage = imageResult.image
                    }
                    .resizable()
                    .scaledToFit()
            }
            
            VStack {
                Spacer()
                
                HStack {
                    VStack {
                        Text("Size" + ": " + imageLoader.size)
                        
                        Text("Resolution: \(Int(imageLoader.dimensions.width)) x \(Int(imageLoader.dimensions.height))".replacingOccurrences(of: ",", with: ""))
                    }
                    .font(.system(.headline, design: .rounded))
                    .redacted(reason: imageLoader.isLoaded ? [] : .placeholder)
                    
                    Spacer()
                    
                    Button {
                        if let inputImage = imageLoader.image {
                            let imageSaver = ImageSaver()
                            imageSaver.writeToPhotoAlbum(image: inputImage)
                        }
                        
                        var imageToUpdate = image
                        imageToUpdate.views += 1
                        image.downloads += 1
                        updateDownloads(imageToUpdate)
                    } label: {
                        Image(systemName: "square.and.arrow.down")
                            .bold()
                            .title2()
                            .padding()
                            .background(Circle().fill(.ultraThinMaterial))
                            .foregroundColor(.white)
                    }
                    
                    ShareLink(item: getUrl(image.name)) {
                        Image(systemName: "square.and.arrow.up")
                            .bold()
                            .title2()
                            .padding()
                            .background(Circle().fill(.ultraThinMaterial))
                            .foregroundColor(.white)
                    }
                }
                .padding(16)
                .background { Rectangle().fill(.ultraThinMaterial) }
            }
        }
        .ignoresSafeArea()
        .task { imageLoader.loadImage(from: getUrl(image.name, false)) }
    }
    
    private func updateDownloads(_ image: AtomicPaper, update: whatToUpdate = .downloads) {
        Task {
            do {
                try await RootVM().updateRecord(image, update: .downloads)
            } catch {
                print(error)
            }
        }
    }
    
    private func loadImageFromCache() {
        KingfisherManager.shared.cache.retrieveImage(forKey: image.name) { result in
            switch result {
            case .success(let imageResult):
                self.cachedImage = imageResult.image
                
            case .failure: break
            }
        }
    }
}

//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView("zina0", downloads: 0, views: 0, podstava: Image(systemName: "hammer").asUIImage())
//            .darkSchemePreferred()
//        
//        ImageView("zina0", downloads: 0, views: 0, podstava: Image(systemName: "hammer").asUIImage())
//    }
//}
