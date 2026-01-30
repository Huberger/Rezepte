import SwiftUI
import SwiftData

@main
struct RecipesApp: App {
    var container: ModelContainer = {
        do {
            return try ModelContainer(for: [Recipe.self, Category.self])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()  

    var body: some Scene {
        WindowGroup {
            RecipeListView()
                .modelContainer(container)
        }
    }
}
