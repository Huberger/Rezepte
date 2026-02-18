import Foundation
import UIKit
import SwiftData
import UniformTypeIdentifiers
import Compression

struct RecipeExporter {
    static func exportRecipes(_ recipes: [Recipe]) -> URL? {
        let exportData = recipes.map { recipe in
            [
                "id": recipe.id.uuidString,
                "title": recipe.title,
                "category": recipe.category?.name ?? "",
                "notes": recipe.notes,
                "createdAt": ISO8601DateFormatter().string(from: recipe.createdAt),
                "imageFileName": recipe.imageData != nil ? "\(recipe.id.uuidString).jpg" : ""
            ]
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted) else {
            return nil
        }
        
        let tempDir = FileManager.default.temporaryDirectory
        let exportDir = tempDir.appendingPathComponent("RezepteExport_\(Date().timeIntervalSince1970)")
        
        do {
            try FileManager.default.createDirectory(at: exportDir, withIntermediateDirectories: true)
            
            // JSON speichern
            let jsonURL = exportDir.appendingPathComponent("recipes.json")
            try jsonData.write(to: jsonURL)
            
            // Bilder speichern
            let imagesDir = exportDir.appendingPathComponent("images")
            try FileManager.default.createDirectory(at: imagesDir, withIntermediateDirectories: true)
            
            for recipe in recipes {
                if let imageData = recipe.imageData {
                    let imageURL = imagesDir.appendingPathComponent("\(recipe.id.uuidString).jpg")
                    try imageData.write(to: imageURL)
                }
            }
            
            // ZIP mit Archive API erstellen (iOS-kompatibel)
            let zipURL = tempDir.appendingPathComponent("Rezepte_\(Date().timeIntervalSince1970).zip")
            
            // Da iOS keine native ZIP-Erstellung ohne externe Bibliothek unterstützt,
            // verwenden wir einen Fallback: Exportverzeichnis direkt teilen
            // Für eine produktionsreife Lösung sollte eine Bibliothek wie ZIPFoundation verwendet werden
            
            // Aufräumen wird übersprungen, damit das Verzeichnis geteilt werden kann
            // try? FileManager.default.removeItem(at: exportDir)
            
            return exportDir
        } catch {
            print("Export-Fehler: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("Fehlerdetails: Domain: \(nsError.domain), Code: \(nsError.code), UserInfo: \(nsError.userInfo)")
            }
            return nil
        }
    }
}
