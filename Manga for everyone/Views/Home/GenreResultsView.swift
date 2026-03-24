import SwiftUI

struct GenreResultsView: View {
    let tag: Tag
    @State private var mangaList: [Manga] = []
    @State private var isLoading = false
    @State private var isFetchingNextPage = false
    @State private var errorMessage: String?
    
    @State private var offset = 0
    private let limit = 20
    @State private var canLoadMore = true
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack {
                if isLoading {
                    ProgressView().padding(.top, 50)
                } else if let error = errorMessage {
                    Text(error).foregroundColor(.red).padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(mangaList) { manga in
                            NavigationLink(destination: DetailView(manga: manga)) {
                                MangaCard(manga: manga)
                                    .onAppear {
                                        if manga.id == mangaList.last?.id {
                                            Task { await fetchNextPage() }
                                        }
                                    }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    
                    if isFetchingNextPage {
                        ProgressView().padding()
                    }
                }
            }
        }
        .navigationTitle(tag.displayName)
        .onAppear {
            if mangaList.isEmpty {
                Task { await fetchManga() }
            }
        }
    }
    
    func fetchManga() async {
        isLoading = true
        errorMessage = nil
        offset = 0
        canLoadMore = true
        do {
            mangaList = try await MangaDexClient.shared.fetchMangaList(limit: limit, offset: offset, includedTags: [tag.id])
            offset += limit
        } catch {
            errorMessage = "Lỗi: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func fetchNextPage() async {
        guard !isFetchingNextPage && canLoadMore else { return }
        
        isFetchingNextPage = true
        do {
            let nextManga = try await MangaDexClient.shared.fetchMangaList(limit: limit, offset: offset, includedTags: [tag.id])
            if nextManga.isEmpty {
                canLoadMore = false
            } else {
                mangaList.append(contentsOf: nextManga)
                offset += limit
            }
        } catch {
            print("Lỗi tải trang tiếp: \(error)")
        }
        isFetchingNextPage = false
    }
}
