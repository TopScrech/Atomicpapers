import CloudKit

enum whatToUpdate {
    case views
    case downloads
}

enum Categories: String, CaseIterable, Identifiable {
    case all
    case twin
    case twins
    case nechaev
    case zina
    case charles
    case other
}

extension Categories {
    var displayName: String {
        rawValue.capitalized
    }
    
    var id: String {
        rawValue
    }
}

struct AtomicPaper: Equatable, Hashable {
    var recordId: CKRecord.ID?
    let name: String
    var downloads, views: Int
}

enum ImageRecordKeys: String {
    case type = "AtomicPaper"
    case name
    case views
}

extension AtomicPaper {
    init?(record: CKRecord) {
        guard let name = record["name"] as? String,
              let downloads = record["downloads"] as? Int,
              let views = record["views"] as? Int else {
            return nil
        }
        
        self.init(recordId: record.recordID, name: name, downloads: downloads, views: views)
    }
}

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let error: Error
    let guidance: String
}
