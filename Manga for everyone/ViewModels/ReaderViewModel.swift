import Foundation
import Combine

@MainActor
class ReaderViewModel: ObservableObject {
    @Published var pages: [URL] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var nextChapter: Chapter?
    
    @Published var chapter: Chapter?
    
    private let chapterId: String
    private let mangaTitle: String
    private let client = MangaDexClient.shared
    private var startTime: Date?
    
    init(chapter: Chapter, mangaTitle: String) {
        self.chapter = chapter
        self.chapterId = chapter.id
        self.mangaTitle = mangaTitle
    }
    
    init(chapterId: String, mangaTitle: String) {
        self.chapterId = chapterId
        self.mangaTitle = mangaTitle
    }
    
    func startTracking() {
        startTime = Date()
    }
    
    func stopTracking() -> Double {
        guard let start = startTime else { return 0 }
        let duration = Date().timeIntervalSince(start)
        startTime = nil
        
        // Tự động đồng bộ tiến độ lên MangaDex
        Task {
            try? await client.markChapterAsRead(chapterId: chapterId)
        }
        
        return duration
    }
    
    func fetchPages() async {
        // Kiểm tra xem đã tải xuống chưa
        let localURLs = DownloadManager.shared.getLocalImageURLs(for: chapterId)
        if !localURLs.isEmpty {
            self.pages = localURLs
            self.isLoading = false
            // Vẫn cần fetch chapter info để phục vụ Auto-next
            try? await fetchChapterInfo()
            if let _ = chapter { Task { await fetchNextChapterInfo() } }
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if chapter == nil {
                try await fetchChapterInfo()
            }
            
            let atHome = try await client.fetchAtHomeServer(chapterId: chapterId)
            pages = client.getPageURLs(atHome: atHome, useDataSaver: AppSettings.shared.isDataSaverEnabled)
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Lỗi: \(error.localizedDescription)"
        }
        
        isLoading = false
        
        // Fetch next chapter in background
        Task { await fetchNextChapterInfo() }
    }
    
    private func fetchChapterInfo() async throws {
        self.chapter = try await client.fetchChapter(id: chapterId)
    }
    
    private func fetchNextChapterInfo() async {
        guard let chapter = chapter,
              let mangaId = chapter.relationships.first(where: { $0.type == "manga" })?.id else { return }
        
        do {
            // Lấy danh sách chapter tiếng Việt của bộ truyện này
            let chapters = try await client.fetchChapters(mangaId: mangaId, translatedLanguage: ["vi"])
            
            // Tìm vị trí chương hiện tại dựa trên chapter number (sắp xếp tăng dần)
            let sortedChapters = chapters.sorted { (c1, c2) -> Bool in
                let n1 = Double(c1.attributes.chapter ?? "0") ?? 0
                let n2 = Double(c2.attributes.chapter ?? "0") ?? 0
                return n1 < n2
            }
            
            if let currentIndex = sortedChapters.firstIndex(where: { $0.id == chapter.id }),
               currentIndex + 1 < sortedChapters.count {
                self.nextChapter = sortedChapters[currentIndex + 1]
            }
        } catch {
            print("Lỗi tìm chương tiếp theo: \(error)")
        }
    }
}
