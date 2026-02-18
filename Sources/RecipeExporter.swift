import Foundation
import UIKit
import SwiftData
import UniformTypeIdentifiers

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
            
            // ZIP erstellen
            let zipURL = tempDir.appendingPathComponent("Rezepte_\(Date().timeIntervalSince1970).zip")
            try FileManager.default.zipItem(at: exportDir, to: zipURL)
            
            // Aufräumen
            try? FileManager.default.removeItem(at: exportDir)
            
            return zipURL
        } catch {
            print("Export-Fehler: \(error)")
            return nil
        }
    }
}

extension FileManager {
    func zipItem(at sourceURL: URL, to destinationURL: URL) throws {
        // Einfache ZIP-Implementierung mit System-Kommando
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        process.arguments = ["-r", destinationURL.path, "."]
        process.currentDirectoryURL = sourceURL
        
        try process.run()
        process.waitUntilExit()
        
        guard process.terminationStatus == 0 else {
            throw NSError(domain: "ZipError", code: Int(process.terminationStatus))
        }
    }
}
