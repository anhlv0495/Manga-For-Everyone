import Foundation
import SwiftData

@Model
class FavoriteManga {
    @Attribute(.unique) var id: String
    var title: String
    var coverURL: String?
    var addedAt: Date
    
    init(id: String, title: String, coverURL: String? = nil) {
        self.id = id
        self.title = title
        self.coverURL = coverURL
        self.addedAt = Date()
    }
}

@Model
class DailyReadingStat {
    var date: Date
    var secondsRead: Double
    
    init(date: Date, secondsRead: Double = 0) {
        self.date = Calendar.current.startOfDay(for: date)
        self.secondsRead = secondsRead
    }
}

@Model
class ReadingHistory {
    @Attribute(.unique) var mangaId: String
    var mangaTitle: String
    var lastChapterId: String
    var lastChapterNumber: String
    var updatedAt: Date
    var readingTime: Double = 0 // Tổng thời gian đọc (giây)
    var pagesRead: Int = 0 // Tổng số trang đã đọc
    
    init(mangaId: String, mangaTitle: String, lastChapterId: String, lastChapterNumber: String) {
        self.mangaId = mangaId
        self.mangaTitle = mangaTitle
        self.lastChapterId = lastChapterId
        self.lastChapterNumber = lastChapterNumber
        self.updatedAt = Date()
    }
}

@Model
class DownloadedChapter {
    @Attribute(.unique) var id: String
    var mangaId: String
    var mangaTitle: String
    var chapterNumber: String
    var pageCount: Int
    var downloadedAt: Date
    var localSubPath: String // Thư mục lưu ảnh (id chương)
    
    init(id: String, mangaId: String, mangaTitle: String, chapterNumber: String, pageCount: Int, localSubPath: String) {
        self.id = id
        self.mangaId = mangaId
        self.mangaTitle = mangaTitle
        self.chapterNumber = chapterNumber
        self.pageCount = pageCount
        self.localSubPath = localSubPath
        self.downloadedAt = Date()
    }
}
