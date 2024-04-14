import ScrechKit
import CloudKit

class RootVM: ObservableObject {
    @Published var imageDictionary: [CKRecord.ID: AtomicPaper] = [:]
    
    var filteredImages: [AtomicPaper] {
        return filterImage(by: filterOption)
    }
    
    var images: [AtomicPaper] {
        imageDictionary.values.compactMap { $0 }
    }
    
    private var db = CKContainer.default().publicCloudDatabase
    
    @Published var hideStats: Bool = true
    @AppStorage("filterOption") var filterOption: Categories = .all
    @Published var errorWrapper: ErrorWrapper?
    
    @Published var objectToUpdateDownloads: AtomicPaper?
    
    func applyFilter(_ option: Categories) {
        hideStats = true
        filterOption = option
        Task {
            await refreshImages()
        }
        delay(1.5) {
            self.hideStats = false
        }
    }
    
    func loadImages() async {
        do {
            try await populateImages()
        } catch {
            print("Error loading images: \(error)")
        }
    }
    
    func refreshImages() async {
        do {
            try await populateImages()
//            sortImagesByViews()
        } catch {
            print("Error refreshing images:", error)
        }
    }
    
//    func sortImagesByViews() {
//        main {
//            self.imageDictionary = self.imageDictionary.sorted { $0.value.views > $1.value.views }.reduce(into: [:]) { $0[$1.0] = $1.1 }
//        }
//    }
    
    func populateImages() async throws {
        let query = CKQuery(recordType: ImageRecordKeys.type.rawValue, predicate: NSPredicate(value: true))
        
        let result = try await db.records(matching: query)
        
        let records = result.matchResults.compactMap {
            try? $0.1.get()
        }
        
        let atomicPapers = records.compactMap { AtomicPaper(record: $0) }
        
        let sortedAtomicPapers = atomicPapers.sorted { atomicPaper1, atomicPaper2 in
            atomicPaper1.views > atomicPaper2.views
        }
        
        sortedAtomicPapers.forEach { atomicPaper in
            main {
                self.imageDictionary[atomicPaper.recordId!] = atomicPaper
            }
        }
    }

    func filterImage(by filterOption: Categories) -> [AtomicPaper] {
        switch filterOption {
        case .all:
            return images
            
        case .twin:
            return images.filter { $0.name.contains("twin") && !$0.name.contains("twins") }
            
        case .zina:
            return images.filter { $0.name.contains("zina") }
            
        case .nechaev:
            return images.filter { $0.name.contains("nechaev") }
            
        default:
            return images.filter { $0.name.contains(filterOption.displayName.lowercased()) }
        }
    }
    
    func updateRecord(_ editedImage: AtomicPaper, update: whatToUpdate) async throws {
        switch update {
        case .views:
            try await performUpdate(for: "views", value: editedImage.views)
        case .downloads:
            try await performUpdate(for: "downloads", value: editedImage.downloads)
        }
        
        func performUpdate(for key: String, value: Int) async throws {
            main {
                if key == "views" {
                    self.imageDictionary[editedImage.recordId!]?.views = value
                } else if key == "downloads" {
                    self.imageDictionary[editedImage.recordId!]?.downloads = value
                }
            }
            
            do {
                let record = try await db.record(for: editedImage.recordId!)
                record[key] = value
                
                try await db.save(record)
//                main { self.sortImagesByViews() }
            } catch {
                print(error)
                main {
                    if key == "views" {
                        self.imageDictionary[editedImage.recordId!]?.views = value
                    } else if key == "downloads" {
                        self.imageDictionary[editedImage.recordId!]?.downloads = value
                    }
                }
            }
        }
    }
}
