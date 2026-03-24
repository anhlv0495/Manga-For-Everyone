import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MangaVN")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.orange)
                        Text("Kho truyện khổng lồ, miễn phí")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Featured Carousel
                    if !viewModel.latestManga.isEmpty {
                        FeaturedCarousel(mangaList: Array(viewModel.latestManga.prefix(5)))
                    }
                    
                    // Genres / Categories Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Thể loại")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.tags) { tag in
                                    NavigationLink(destination: GenreResultsView(tag: tag)) {
                                        Text(tag.displayName)
                                            .font(.subheadline)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.orange.opacity(0.1))
                                            .foregroundColor(.orange)
                                            .cornerRadius(20)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Featured / Latest Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mới cập nhật")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.isLoading && viewModel.latestManga.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 400)
                    } else if let error = viewModel.errorMessage {
                        VStack(spacing: 12) {
                            Text(error)
                                .foregroundColor(.red)
                            Button("Thử lại") {
                                Task { await viewModel.fetchLatest() }
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 400)
                    } else {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.latestManga) { manga in
                                NavigationLink(destination: DetailView(manga: manga)) {
                                    MangaCard(manga: manga)
                                        .onAppear {
                                            if manga.id == viewModel.latestManga.last?.id {
                                                Task { await viewModel.fetchNextPage() }
                                            }
                                        }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // Loading indicator for next page
                        if viewModel.isFetchingNextPage {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                } // End of Featured VStack (line 55)
            } // End of Main VStack (line 14)
            .padding(.top)
        } // End of ScrollView (line 13)
        .navigationBarHidden(true)
        .onAppear {
            if viewModel.latestManga.isEmpty {
                Task { 
                    await viewModel.fetchLatest()
                    await viewModel.fetchTags()
                }
            }
        }
        }
    }
}

struct FeaturedCarousel: View {
    let mangaList: [Manga]
    
    var body: some View {
        TabView {
            ForEach(mangaList) { manga in
                NavigationLink(destination: DetailView(manga: manga)) {
                    ZStack(alignment: .bottomLeading) {
                        AsyncImage(url: manga.coverURL) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.1)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        
                        // Glassmorphism overlay
                        VStack(alignment: .leading, spacing: 4) {
                            Text(manga.displayTitle)
                                .font(.headline)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Text(manga.attributes.status.capitalized)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.ultraThinMaterial)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .frame(height: 250)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
