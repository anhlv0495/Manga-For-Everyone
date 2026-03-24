import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var showFilterSheet = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Tìm tên truyện...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    Button(action: { showFilterSheet = true }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
                .sheet(isPresented: $showFilterSheet) {
                    FilterSheet(
                        selectedStatus: $viewModel.selectedStatus,
                        selectedDemographics: $viewModel.selectedDemographics,
                        selectedOrder: $viewModel.selectedOrder
                    )
                    .onDisappear {
                        if !viewModel.searchText.isEmpty {
                            Task { await viewModel.performSearch(query: viewModel.searchText) }
                        }
                    }
                }
                
                if viewModel.isSearching {
                    ProgressView().padding()
                } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Không tìm thấy truyện nào")
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 50)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.searchResults) { manga in
                                NavigationLink(destination: DetailView(manga: manga)) {
                                    MangaCard(manga: manga)
                                        .onAppear {
                                            if manga.id == viewModel.searchResults.last?.id {
                                                Task { await viewModel.fetchNextPage() }
                                            }
                                        }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        if viewModel.isFetchingNextPage {
                            ProgressView().padding()
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Tìm kiếm")
        }
    }
}
