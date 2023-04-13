import ScrechKit
import CloudKit

class RootVM: ObservableObject {
    private var db = CKContainer.default().publicCloudDatabase
    
    @Published var hideStats: Bool = true
    @Published var filterOption: Categories = .all
    @Published var errorWrapper: ErrorWrapper?
    @Published var imageDictionary: [CKRecord.ID: AtomicPaper] = [:]
    
    @Published var objectToUpdateDownloads: AtomicPaper?
    
    var filteredImages: [AtomicPaper] {
        return filterImage(by: filterOption)
    }
    
    var images: [AtomicPaper] {
        imageDictionary.values.compactMap { $0 }
    }
    
    func refreshImages() async {
        main {
            self.imageDictionary.removeAll()
        }
        do {
            try await populateImages()
            sortImagesByViews()
        } catch {
            print("Error refreshing images:", error)
        }
    }
    
    func sortImagesByViews() {
        main {
            self.imageDictionary = self.imageDictionary.sorted { $0.value.views > $1.value.views }.reduce(into: [:]) { $0[$1.0] = $1.1 }
        }
    }
    
    func populateImages() async throws {
        let query = CKQuery(recordType: ImageRecordKeys.type.rawValue, predicate: NSPredicate(value: true))
        
        let result = try await db.records(matching: query)
        
        let records = result.matchResults.compactMap {
            try? $0.1.get()
        }
        
        records.forEach { record in
            main {
                self.imageDictionary[record.recordID] = AtomicPaper(record: record)
            }
        }
    }
    
    func filterImage(by filterOption: Categories) -> [AtomicPaper] {
        switch filterOption {
        case .all:
            return images
            
        case .twin:
            return images.filter({ $0.name.contains("twin") && !$0.name.contains("twins") })
            
        case .zina:
            return images.filter({ $0.name.contains("zina") })
            
        default:
            return images.filter({ $0.name.contains(filterOption.displayName.lowercased()) })
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
                main { self.sortImagesByViews() }
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
