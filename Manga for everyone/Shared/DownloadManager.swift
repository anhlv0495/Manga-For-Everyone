import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
class DownloadManager: ObservableObject {
    static let shared = DownloadManager()
    
    @Published var downloadingChapters: Set<String> = []
    @Published var downloadProgress: [String: Double] = [:]
    
    private let fileManager = FileManager.default
    private let client = MangaDexClient.shared
    
    private var documentsDirectory: URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var downloadsDirectory: URL {
        let url = documentsDirectory.appendingPathComponent("Downloads")
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
        return url
    }
    
    func downloadChapter(_ chapter: Chapter, mangaTitle: String, modelContext: ModelContext) async {
        let chapterId = chapter.id
        guard !downloadingChapters.contains(chapterId) else { return }
        
        downloadingChapters.insert(chapterId)
        downloadProgress[chapterId] = 0.0
        
        do {
            let atHome = try await client.fetchAtHomeServer(chapterId: chapterId)
            let urls = client.getPageURLs(atHome: atHome, useDataSaver: AppSettings.shared.isDataSaverEnabled)
            
            let chapterFolder = downloadsDirectory.appendingPathComponent(chapterId)
            if !fileManager.fileExists(atPath: chapterFolder.path) {
                try fileManager.createDirectory(at: chapterFolder, withIntermediateDirectories: true)
            }
            
            var downloadedCount = 0
            for (index, url) in urls.enumerated() {
                let (data, _) = try await URLSession.shared.data(from: url)
                let filePath = chapterFolder.appendingPathComponent("\(index).jpg")
                try data.write(to: filePath)
                
                downloadedCount += 1
                downloadProgress[chapterId] = Double(downloadedCount) / Double(urls.count)
            }
            
            // Save to SwiftData
            let mangaId = chapter.relationships.first(where: { $0.type == "manga" })?.id ?? ""
            let downloadedChapter = DownloadedChapter(
                id: chapterId,
                mangaId: mangaId,
                mangaTitle: mangaTitle,
                chapterNumber: chapter.attributes.chapter ?? "?",
                pageCount: urls.count,
                localSubPath: chapterId
            )
            modelContext.insert(downloadedChapter)
            try modelContext.save()
            
        } catch {
            print("Lỗi tải chương: \(error)")
        }
        
        downloadingChapters.remove(chapterId)
        downloadProgress.removeValue(forKey: chapterId)
    }
    
    func getLocalImageURLs(for chapterId: String) -> [URL] {
        let chapterFolder = downloadsDirectory.appendingPathComponent(chapterId)
        guard fileManager.fileExists(atPath: chapterFolder.path) else { return [] }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: chapterFolder, includingPropertiesForKeys: nil)
            return files.sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
        } catch {
            return []
        }
    }
    
    func deleteDownload(chapterId: String, modelContext: ModelContext) {
        let chapterFolder = downloadsDirectory.appendingPathComponent(chapterId)
        try? fileManager.removeItem(at: chapterFolder)
        
        // Remove from SwiftData
        let predicate = #Predicate<DownloadedChapter> { $0.id == chapterId }
        try? modelContext.delete(model: DownloadedChapter.self, where: predicate)
    }
}
