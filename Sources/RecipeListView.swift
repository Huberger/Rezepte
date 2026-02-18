import SwiftUI
import SwiftData
import UIKit

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var recipes: [Recipe]
    @Query private var categories: [Category]
    
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .dateDescending
    @State private var showingAddRecipe = false
    @State private var exportURL: URL?
    @State private var showingShareSheet = false
    
    enum SortOrder {
        case dateAscending
        case dateDescending
        case titleAscending
        case titleDescending
    }
    
    var filteredAndSortedRecipes: [Recipe] {
        var filtered = recipes
        
        if !searchText.isEmpty {
            filtered = filtered.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.notes.localizedCaseInsensitiveContains(searchText) ||
                recipe.category?.name.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        return filtered.sorted { first, second in
            switch sortOrder {
            case .dateAscending:
                return first.createdAt < second.createdAt
            case .dateDescending:
                return first.createdAt > second.createdAt
            case .titleAscending:
                return first.title < second.title
            case .titleDescending:
                return first.title > second.title
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredAndSortedRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeRow(recipe: recipe)
                    }
                }
                .onDelete(perform: deleteRecipes)
            }
            .navigationTitle("Rezepte")
            .searchable(text: $searchText, prompt: "Suchen...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sortieren", selection: $sortOrder) {
                            Text("Neueste zuerst").tag(SortOrder.dateDescending)
                            Text("Älteste zuerst").tag(SortOrder.dateAscending)
                            Text("Titel A-Z").tag(SortOrder.titleAscending)
                            Text("Titel Z-A").tag(SortOrder.titleDescending)
                        }
                    } label: {
                        Label("Sortieren", systemImage: "arrow.up.arrow.down")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddRecipe = true }) {
                        Label("Hinzufügen", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: exportRecipes) {
                        Label("Exportieren", systemImage: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func deleteRecipes(at offsets: IndexSet) {
        for index in offsets {
            let recipe = filteredAndSortedRecipes[index]
            modelContext.delete(recipe)
        }
    }
    
    private func exportRecipes() {
        guard !recipes.isEmpty else { return }
        
        if let url = RecipeExporter.exportRecipes(recipes) {
            exportURL = url
            showingShareSheet = true
        }
    }
}

struct RecipeRow: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageData = recipe.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                
                if let category = recipe.category {
                    Text(category.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !recipe.notes.isEmpty {
                    Text(recipe.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

#Preview {
    RecipeListView()
        .modelContainer(for: [Recipe.self, Category.self], inMemory: true)
}
