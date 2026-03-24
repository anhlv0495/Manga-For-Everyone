import SwiftUI
import SwiftData

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @Environment(\.modelContext) private var modelContext
    @Query var favorites: [FavoriteManga]
    
    var isFavorite: Bool {
        guard let manga = viewModel.manga else { return false }
        return favorites.contains { $0.id == manga.id }
    }
    
    init(manga: Manga) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(manga: manga))
    }
    
    init(mangaId: String) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(mangaId: mangaId))
    }
    
    var body: some View {
        Group {
            if let manga = viewModel.manga {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Cover and Basic Info
                        HStack(alignment: .top, spacing: 16) {
                            AsyncImage(url: manga.coverURL) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle().fill(Color.gray.opacity(0.1))
                            }
                            .frame(width: 120, height: 180)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text(manga.displayTitle)
                                    .font(.title3)
                                    .bold()
                                
                                Button(action: toggleFavorite) {
                                    Label(isFavorite ? "Đã thích" : "Yêu thích", systemImage: isFavorite ? "heart.fill" : "heart")
                                        .font(.caption)
                                        .foregroundColor(isFavorite ? .red : .primary)
                                        .padding(8)
                                        .background(Capsule().stroke(isFavorite ? Color.red : Color.gray, lineWidth: 1))
                                }
                                
                                Text("Trạng thái: \(manga.attributes.status.capitalized)")
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                                
                                if let lastChapter = manga.attributes.lastChapter {
                                    Text("Chương mới nhất: \(lastChapter)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Giới thiệu")
                                .font(.headline)
                            Text(manga.displayDescription)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .lineLimit(5)
                        }
                        .padding(.horizontal)
                        
                        Divider().padding(.vertical, 8)
                        
                        // Chapters
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Danh sách chương")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if viewModel.isLoading {
                                ProgressView().frame(maxWidth: .infinity).padding(20)
                            } else if let error = viewModel.errorMessage {
                                Text(error).foregroundColor(.red).padding()
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.chapters) { chapter in
                                        NavigationLink(destination: ReaderView(chapter: chapter, mangaTitle: manga.displayTitle)) {
                                            ChapterRow(chapter: chapter, mangaTitle: manga.displayTitle)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Related Manga Section
                        if !viewModel.relatedManga.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Truyện liên quan")
                                    .font(.headline)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(viewModel.relatedManga) { manga in
                                            NavigationLink(destination: DetailView(manga: manga)) {
                                                VStack(alignment: .leading) {
                                                    AsyncImage(url: manga.coverURL) { image in
                                                        image.resizable().aspectRatio(contentMode: .fill)
                                                    } placeholder: {
                                                        Rectangle().fill(Color.gray.opacity(0.1))
                                                    }
                                                    .frame(width: 100, height: 150)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    
                                                    Text(manga.displayTitle)
                                                        .font(.caption)
                                                        .bold()
                                                        .lineLimit(2)
                                                        .frame(width: 100)
                                                }
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            } else if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                VStack {
                    Text(error).foregroundColor(.red)
                    Button("Thử lại") {
                        Task { await viewModel.fetchMangaDetail() }
                    }
                }
            } else {
                Color.clear
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task { await viewModel.fetchMangaDetail() }
        }
    }
    
    private func toggleFavorite() {
        guard let manga = viewModel.manga else { return }
        if isFavorite {
            if let fav = favorites.first(where: { $0.id == manga.id }) {
                modelContext.delete(fav)
            }
        } else {
            let newFav = FavoriteManga(id: manga.id, title: manga.displayTitle, coverURL: manga.coverURL?.absoluteString)
            modelContext.insert(newFav)
        }
    }
}

struct ChapterRow: View {
    let chapter: Chapter
    let mangaTitle: String
    
    @Environment(\.modelContext) private var modelContext
    @Query var downloads: [DownloadedChapter]
    @ObservedObject var downloadManager = DownloadManager.shared
    
    var isDownloaded: Bool {
        downloads.contains { $0.id == chapter.id }
    }
    
    var isDownloading: Bool {
        downloadManager.downloadingChapters.contains(chapter.id)
    }
    
    var progress: Double {
        downloadManager.downloadProgress[chapter.id] ?? 0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Chương \(chapter.attributes.chapter ?? "??")")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let title = chapter.attributes.title, !title.isEmpty {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Download Button
            if isDownloaded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if isDownloading {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.orange, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .rotationEffect(.degrees(-90))
                }
            } else {
                Button(action: {
                    Task {
                        await downloadManager.downloadChapter(chapter, mangaTitle: mangaTitle, modelContext: modelContext)
                    }
                }) {
                    Image(systemName: "arrow.down.circle")
                        .font(.title3)
                        .foregroundColor(.orange)
                }
            }
            
            // Language Badge
            Text(chapter.attributes.translatedLanguage.uppercased())
                .font(.system(size: 10, weight: .bold))
                .padding(4)
                .background(chapter.attributes.translatedLanguage == "vi" ? Color.orange.opacity(0.1) : Color.gray.opacity(0.1))
                .foregroundColor(chapter.attributes.translatedLanguage == "vi" ? .orange : .secondary)
                .cornerRadius(4)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}
