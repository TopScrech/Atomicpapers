import ScrechKit
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var size: String = "Loading..."
    @Published var isLoaded: Bool = false
    @Published var dimensions: CGSize = CGSize.zero
    
    private var cancellable: AnyCancellable?
    
    func loadImage(_ url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .failure(let error):
                    print("Error downloading image: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { data in
                if let downloadedImage = UIImage(data: data) {
                    main {
                        self.image = downloadedImage
                        
                        withAnimation {
                            self.size = formatBytes(data.count)
                            self.dimensions = downloadedImage.size
                            self.isLoaded = true
                        }
                    }
                }
            }
    }
}
