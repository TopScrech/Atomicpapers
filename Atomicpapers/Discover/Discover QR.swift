import SwiftUI
import CoreImage.CIFilterBuiltins

struct DiscoverQR: View {
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    let urlString: String
    
    var body: some View {
        VStack {
            Image(uiImage: generateQRCode())
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        }
    }
    
    func generateQRCode() -> UIImage {
        filter.message = Data(urlString.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

struct DiscoverQR_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverQR(urlString: "https://topscrech.dev")
    }
}
