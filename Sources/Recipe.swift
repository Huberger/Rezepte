import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var title: String
    var category: Category?
    @Attribute(.externalStorage) var imageData: Data?
    var notes: String
    var createdAt: Date
    
    init(title: String, category: Category? = nil, imageData: Data? = nil, notes: String = "") {
        self.id = UUID()
        self.title = title
        self.category = category
        self.imageData = imageData
        self.notes = notes
        self.createdAt = Date()
    }
}
