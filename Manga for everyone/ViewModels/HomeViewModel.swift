import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var latestManga: [Manga] = []
    @Published var tags: [Tag] = []
    @Published var isLoading = false
    @Published var isFetchingNextPage = false
    @Published var isLoadingTags = false
    @Published var errorMessage: String?
    
    private var offset = 0
    private let limit = 20
    private var canLoadMore = true
    
    private let client = MangaDexClient.shared
    
    func fetchLatest() async {
        isLoading = true
        errorMessage = nil
        offset = 0
        canLoadMore = true
        
        do {
            latestManga = try await client.fetchMangaList(limit: limit, offset: offset)
            offset += limit
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Lỗi không xác định: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchNextPage() async {
        guard !isFetchingNextPage && canLoadMore else { return }
        
        isFetchingNextPage = true
        do {
            let nextManga = try await client.fetchMangaList(limit: limit, offset: offset)
            if nextManga.isEmpty {
                canLoadMore = false
            } else {
                latestManga.append(contentsOf: nextManga)
                offset += limit
            }
        } catch {
            print("Lỗi tải trang tiếp: \(error)")
        }
        isFetchingNextPage = false
    }
    
    func fetchTags() async {
        isLoadingTags = true
        do {
            let allTags = try await client.fetchTags()
            // Chỉ lấy các tag thuộc nhóm "genre" hoặc "theme" để làm thể loại chính
            tags = allTags.filter { $0.attributes.group == "genre" || $0.attributes.group == "theme" }
        } catch {
            print("Lỗi lấy tags: \(error)")
        }
        isLoadingTags = false
    }
}
