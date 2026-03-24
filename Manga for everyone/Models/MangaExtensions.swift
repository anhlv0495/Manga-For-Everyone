import Foundation

extension Manga {
    /// Lấy tiêu đề ưu tiên tiếng Anh hoặc key đầu tiên (thường là tiếng Nhật/Gốc)
    var displayTitle: String {
        attributes.title["en"] ?? attributes.title.values.first ?? "Không rõ tiêu đề"
    }
    
    /// Lấy mô tả ưu tiên tiếng Việt -> tiếng Anh -> đầu tiên
    var displayDescription: String {
        attributes.description["vi"] ?? attributes.description["en"] ?? attributes.description.values.first ?? ""
    }
    
    var coverURL: URL? {
        MangaDexClient.shared.getCoverURL(manga: self)
    }
    
    var authorName: String? {
        // Tìm trong relationships type "author"
        // Lưu ý: MD API trả về name nếu có tham số `includes[]`
        // Ở đây ta giả định đã truyền `includes[]` và backend map attributes
        // (Trong thực tế có thể cần decode RelationshipAttributes cho Author)
        nil // Tạm thời để sau
    }
}
