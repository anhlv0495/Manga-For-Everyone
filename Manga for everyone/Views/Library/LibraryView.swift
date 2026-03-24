import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \FavoriteManga.addedAt, order: .reverse) var favorites: [FavoriteManga]
    @Query(sort: \ReadingHistory.updatedAt, order: .reverse) var history: [ReadingHistory]
    @Query(sort: \DownloadedChapter.downloadedAt, order: .reverse) var downloads: [DownloadedChapter]
    
    @State private var selectedTab = 0
    @Environment(\.modelContext) private var modelContext
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Loại", selection: $selectedTab) {
                    Text("Yêu thích").tag(0)
                    Text("Lịch sử").tag(1)
                    Text("Đã tải").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                ScrollView {
                    if selectedTab == 0 {
                        if favorites.isEmpty {
                            EmptyLibraryView(title: "Chưa có truyện yêu thích", icon: "heart.slash")
                        } else {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(favorites) { fav in
                                    NavigationLink(destination: DetailView(mangaId: fav.id)) {
                                        FavoriteCard(fav: fav)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else if selectedTab == 1 {
                        if history.isEmpty {
                            EmptyLibraryView(title: "Lịch sử trống", icon: "clock")
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(history) { record in
                                    HistoryRow(record: record)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        if downloads.isEmpty {
                            EmptyLibraryView(title: "Chưa có bản tải xuống", icon: "arrow.down.circle")
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(downloads) { download in
                                    DownloadRow(download: download, modelContext: modelContext)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Thư viện")
            .toolbar {
                if AuthManager.shared.isAuthenticated {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: syncMangaDex) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                    }
                }
            }
        }
    }
    
    private func syncMangaDex() {
        Task {
            do {
                let followed = try await MangaDexClient.shared.fetchFollowedManga()
                // Sync with local favorites
                for manga in followed {
                    if !favorites.contains(where: { $0.id == manga.id }) {
                        let newFav = FavoriteManga(id: manga.id, title: manga.displayTitle, coverURL: manga.coverURL?.absoluteString)
                        modelContext.insert(newFav)
                    }
                }
                try? modelContext.save()
            } catch {
                print("Lỗi đồng bộ: \(error)")
            }
        }
    }
}

struct EmptyLibraryView: View {
    let title: String
    let icon: String
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            Text(title)
                .foregroundColor(.secondary)
        }
        .padding(.top, 100)
    }
}

struct FavoriteCard: View {
    let fav: FavoriteManga
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: fav.coverURL ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.1))
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text(fav.title)
                .font(.subheadline)
                .bold()
                .lineLimit(2)
        }
    }
}

struct HistoryRow: View {
    let record: ReadingHistory
    var body: some View {
        NavigationLink(destination: ReaderView(chapterId: record.lastChapterId, mangaTitle: record.mangaTitle)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.mangaTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Text("Đã đọc đến: Chương \(record.lastChapterNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DownloadRow: View {
    let download: DownloadedChapter
    let modelContext: ModelContext
    
    var body: some View {
        NavigationLink(destination: ReaderView(chapterId: download.id, mangaTitle: download.mangaTitle)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(download.mangaTitle)
                        .font(.headline)
                        .lineLimit(1)
                    Text("Chương \(download.chapterNumber) • \(download.pageCount) trang")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    DownloadManager.shared.deleteDownload(chapterId: download.id, modelContext: modelContext)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(8)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
