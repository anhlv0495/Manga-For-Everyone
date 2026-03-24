import SwiftUI

struct MangaCard: View {
    let manga: Manga
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover Image
            AsyncImage(url: manga.coverURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.1))
                        .overlay(Image(systemName: "photo").foregroundColor(.gray))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(manga.displayTitle)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let lastChapter = manga.attributes.lastChapter {
                    Text("Chapter \(lastChapter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 140)
    }
}
