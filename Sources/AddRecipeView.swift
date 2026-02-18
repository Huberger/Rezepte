import SwiftUI
import SwiftData
import PhotosUI

struct AddRecipeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [Category]
    
    @State private var title = ""
    @State private var notes = ""
    @State private var selectedCategory: Category?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var newCategoryName = ""
    @State private var showingNewCategory = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Rezeptdetails") {
                    TextField("Titel", text: $title)
                    
                    Picker("Kategorie", selection: $selectedCategory) {
                        Text("Keine").tag(nil as Category?)
                        ForEach(categories) { category in
                            Text(category.name).tag(category as Category?)
                        }
                    }
                    
                    Button("Neue Kategorie") {
                        showingNewCategory = true
                    }
                }
                
                Section("Foto") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let imageData = imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        } else {
                            Label("Foto auswählen", systemImage: "photo.on.rectangle")
                        }
                    }
                    .onChange(of: selectedPhoto) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                imageData = compressImage(data)
                            }
                        }
                    }
                }
                
                Section("Bemerkungen") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Rezept hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        saveRecipe()
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("Neue Kategorie", isPresented: $showingNewCategory) {
                TextField("Kategorienname", text: $newCategoryName)
                Button("Abbrechen", role: .cancel) {
                    newCategoryName = ""
                }
                Button("Hinzufügen") {
                    addCategory()
                }
            }
        }
    }
    
    private func saveRecipe() {
        let recipe = Recipe(
            title: title,
            category: selectedCategory,
            imageData: imageData,
            notes: notes
        )
        modelContext.insert(recipe)
    }
    
    private func addCategory() {
        guard !newCategoryName.isEmpty else { return }
        let category = Category(name: newCategoryName)
        modelContext.insert(category)
        selectedCategory = category
        newCategoryName = ""
    }
    
    private func compressImage(_ data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return data }
        
        // Maximale Bildgröße (z.B. 1024x1024)
        let maxSize: CGFloat = 1024
        let scale = min(maxSize / image.size.width, maxSize / image.size.height, 1.0)
        
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // JPEG-Kompression mit 80% Qualität
        return resizedImage?.jpegData(compressionQuality: 0.8) ?? data
    }
}

#Preview {
    AddRecipeView()
        .modelContainer(for: [Recipe.self, Category.self], inMemory: true)
}
