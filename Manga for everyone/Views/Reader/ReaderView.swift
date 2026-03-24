import SwiftUI
import SwiftData

struct ReaderView: View {
    let mangaTitle: String
    @StateObject private var viewModel: ReaderViewModel
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.modelContext) private var modelContext
    @Query var history: [ReadingHistory]
    
    @State private var showControls = true
    
    init(chapter: Chapter, mangaTitle: String) {
        self.mangaTitle = mangaTitle
        _viewModel = StateObject(wrappedValue: ReaderViewModel(chapter: chapter, mangaTitle: mangaTitle))
    }
    
    init(chapterId: String, mangaTitle: String) {
        self.mangaTitle = mangaTitle
        _viewModel = StateObject(wrappedValue: ReaderViewModel(chapterId: chapterId, mangaTitle: mangaTitle))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView().tint(.white)
            } else if let error = viewModel.errorMessage {
                Text(error).foregroundColor(.red)
            } else {
                if settings.readingMode == .vertical {
                    ScrollView {
                        LazyVStack(spacing: settings.pageGap) {
                            ForEach(viewModel.pages, id: \.self) { url in
                                ReaderImage(url: url)
                            }
                            
                            if let next = viewModel.nextChapter {
                                NextChapterButton(chapter: next, mangaTitle: mangaTitle)
                            }
                        }
                    }
                } else {
                    TabView {
                        ForEach(viewModel.pages, id: \.self) { url in
                            ReaderImage(url: url)
                                .tag(url)
                        }
                        
                        if let next = viewModel.nextChapter {
                            NextChapterButton(chapter: next, mangaTitle: mangaTitle)
                                .tag("next_chapter")
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            
            // Blue Light Filter Overlay
            if settings.blueLightFilter > 0 {
                Color.orange.opacity(settings.blueLightFilter)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onTapGesture {
            withAnimation { showControls.toggle() }
        }
        .overlay(alignment: .top) {
            if showControls {
                ReaderTopBar(title: "Chương \(viewModel.chapter?.attributes.chapter ?? "??")").transition(.move(edge: .top))
            }
        }
        .overlay(alignment: .bottom) {
            if showControls {
                ReaderBottomBar().transition(.move(edge: .bottom))
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            Task { 
                await viewModel.fetchPages()
                updateHistory()
                viewModel.startTracking()
            }
        }
        .onDisappear {
            let duration = viewModel.stopTracking()
            saveStats(duration: duration)
        }
    }
    
    private func saveStats(duration: Double) {
        guard let chapter = viewModel.chapter,
              let mangaId = chapter.relationships.first(where: { $0.type == "manga" })?.id else { return }
        
        // Update per-manga history
        if let existing = history.first(where: { $0.mangaId == mangaId }) {
            existing.readingTime += duration
            existing.pagesRead += viewModel.pages.count
        }
        
        // Update daily stats
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<DailyReadingStat>(
            predicate: #Predicate<DailyReadingStat> { $0.date == today }
        )
        let dailyStats = try? modelContext.fetch(descriptor)
        
        if let existingDaily = dailyStats?.first {
            existingDaily.secondsRead += duration
        } else {
            let newDaily = DailyReadingStat(date: today, secondsRead: duration)
            modelContext.insert(newDaily)
        }
        
        try? modelContext.save()
    }
    
    private func updateHistory() {
        // Tìm mangaId từ relationships của chapter
        guard let chapter = viewModel.chapter,
              let mangaId = chapter.relationships.first(where: { $0.type == "manga" })?.id else { return }
        
        if let existing = history.first(where: { $0.mangaId == mangaId }) {
            existing.lastChapterId = chapter.id
            existing.lastChapterNumber = chapter.attributes.chapter ?? "?"
            existing.updatedAt = Date()
        } else {
            let newRecord = ReadingHistory(mangaId: mangaId, mangaTitle: mangaTitle, lastChapterId: chapter.id, lastChapterNumber: chapter.attributes.chapter ?? "?")
            modelContext.insert(newRecord)
        }
    }
}

struct ReaderImage: View {
    let url: URL
    
    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 400)
        }
        .background(Color.black)
    }
}

struct ReaderTopBar: View {
    let title: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .padding()
                    .background(Circle().fill(Color.black.opacity(0.5)))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.black.opacity(0.5)))
            
            Spacer()
            
            // Settings Button placeholder
            Button(action: {}) {
                Image(systemName: "gear")
                    .padding()
                    .background(Circle().fill(Color.black.opacity(0.5)))
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .top, endPoint: .bottom))
    }
}

struct ReaderBottomBar: View {
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                Button(action: {
                    settings.readingMode = settings.readingMode == .vertical ? .horizontal : .vertical
                }) {
                    VStack {
                        Image(systemName: settings.readingMode == .vertical ? "arrow.up.and.down" : "arrow.left.and.right")
                        Text(settings.readingMode.rawValue).font(.caption2)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    settings.isDataSaverEnabled.toggle()
                }) {
                    VStack {
                        Image(systemName: settings.isDataSaverEnabled ? "leaf.fill" : "leaf")
                        Text("Tiết kiệm").font(.caption2)
                    }
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(BlurView(style: .systemUltraThinMaterialDark).clipShape(Capsule()))
            .padding()
        }
        .background(LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .top, endPoint: .bottom))
    }
}

// Helper for next chapter button
struct NextChapterButton: View {
    let chapter: Chapter
    let mangaTitle: String
    
    var body: some View {
        NavigationLink(destination: ReaderView(chapter: chapter, mangaTitle: mangaTitle)) {
            VStack(spacing: 12) {
                Divider().background(Color.gray.opacity(0.3))
                
                Text("Hết chương rồi!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top)
                
                HStack {
                    Text("Đọc chương tiếp: \(chapter.attributes.chapter ?? "?")")
                        .font(.headline)
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity)
            .background(Color.black)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
