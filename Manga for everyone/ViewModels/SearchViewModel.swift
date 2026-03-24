import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [Manga] = []
    @Published var isSearching = false
    @Published var isFetchingNextPage = false
    @Published var errorMessage: String?
    
    @Published var selectedStatus: [String] = []
    @Published var selectedDemographics: [String] = []
    @Published var selectedOrder: String = "latestUploadedChapter"
    
    private var offset = 0
    private let limit = 20
    private var canLoadMore = true
    private var cancellables = Set<AnyCancellable>()
    private let client = MangaDexClient.shared
    
    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] text in
                if text.isEmpty {
                    self?.searchResults = []
                } else {
                    Task { await self?.performSearch(query: text) }
                }
            }
            .store(in: &cancellables)
    }
    
    func performSearch(query: String) async {
        isSearching = true
        errorMessage = nil
        offset = 0
        canLoadMore = true
        
        let orderDict = [selectedOrder: "desc"]
        
        do {
            searchResults = try await client.fetchMangaList(
                limit: limit, 
                offset: offset, 
                title: query,
                status: selectedStatus,
                demographic: selectedDemographics,
                order: orderDict
            )
            offset += limit
        } catch let error as NetworkError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Lỗi tìm kiếm: \(error.localizedDescription)"
        }
        
        isSearching = false
    }
    
    func fetchNextPage() async {
        guard !isFetchingNextPage && canLoadMore && !searchText.isEmpty else { return }
        
        isFetchingNextPage = true
        let orderDict = [selectedOrder: "desc"]
        
        do {
            let nextManga = try await client.fetchMangaList(
                limit: limit, 
                offset: offset, 
                title: searchText,
                status: selectedStatus,
                demographic: selectedDemographics,
                order: orderDict
            )
            if nextManga.isEmpty {
                canLoadMore = false
            } else {
                searchResults.append(contentsOf: nextManga)
                offset += limit
            }
        } catch {
            print("Lỗi tải thêm kết quả tìm kiếm: \(error)")
        }
        isFetchingNextPage = false
    }
}
