import SwiftUI
import SwiftData

struct RecipeDetailView: View {
    @Bindable var recipe: Recipe
    @State private var isEditingNotes = false
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Bild mit Zoom-Funktionalität
                if let imageData = recipe.imageData,
                   let uiImage = UIImage(data: imageData) {
                    ZoomableImage(uiImage: uiImage)
                        .frame(maxHeight: 400)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    // Kategorie
                    if let category = recipe.category {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.secondary)
                            Text(category.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Erstellt am
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text("Erstellt: \(recipe.createdAt.formatted(date: .long, time: .omitted))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Bemerkungen
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Bemerkungen")
                                .font(.headline)
                            Spacer()
                            Button(isEditingNotes ? "Fertig" : "Bearbeiten") {
                                isEditingNotes.toggle()
                            }
                            .font(.subheadline)
                        }
                        
                        if isEditingNotes {
                            TextEditor(text: $recipe.notes)
                                .frame(minHeight: 150)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        } else {
                            if recipe.notes.isEmpty {
                                Text("Keine Bemerkungen")
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                Text(recipe.notes)
                                    .padding(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ZoomableImage: View {
    let uiImage: UIImage
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale = min(max(scale * delta, 1.0), 4.0)
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            if scale <= 1.0 {
                                withAnimation(.spring()) {
                                    scale = 1.0
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if scale > 1.0 {
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        if scale > 1.0 {
                            scale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2.0
                        }
                    }
                }
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(title: "Beispielrezept", notes: "Dies sind Bemerkungen zum Rezept."))
    }
    .modelContainer(for: [Recipe.self, Category.self], inMemory: true)
}
