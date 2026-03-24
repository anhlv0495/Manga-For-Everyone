import Foundation
import Combine

@MainActor
class DetailViewModel: ObservableObject {
    @Published var chapters: [Chapter] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var relatedManga: [Manga] = []
    
    @Published var manga: Manga?
    
    private let mangaId: String
    private let client = MangaDexClient.shared
    
    init(manga: Manga) {
        self.manga = manga
        self.mangaId = manga.id
    }
    
    init(mangaId: String) {
        self.mangaId = mangaId
    }
    
    func fetchMangaDetail() async {
        if manga != nil {
            await fetchChapters()
            return
        }
        isLoading = true
        do {
            self.manga = try await client.fetchManga(id: mangaId)
            await fetchChapters()
            await fetchRelated()
        } catch {
            errorMessage = "Lỗi tải thông tin truyện: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func fetchChapters() async {
        isLoading = true
        errorMessage = nil
        
        do {
            chapters = try await client.fetchChapters(mangaId: mangaId, order: ["chapter": "desc"])
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Lỗi: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchRelated() async {
        do {
            self.relatedManga = try await client.fetchRelatedManga(mangaId: mangaId)
        } catch {
            print("Lỗi tải truyện liên quan: \(error)")
        }
    }
}
