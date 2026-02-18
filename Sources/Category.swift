import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    @Relationship(deleteRule: .nullify, inverse: \Recipe.category) var recipes: [Recipe]?
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.recipes = []
    }
}
