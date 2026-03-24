import Foundation

// MARK: - API Response Wrapper
struct APIResponse<T: Codable>: Codable {
    let result: String
    let response: String
    let data: T
}

struct APIListResponse<T: Codable>: Codable {
    let result: String
    let response: String
    let data: [T]
    let limit: Int
    let offset: Int
    let total: Int
}

// MARK: - Manga Models
struct Manga: Codable, Identifiable {
    let id: String
    let type: String
    let attributes: MangaAttributes
    let relationships: [Relationship]
}

struct MangaAttributes: Codable {
    let title: [String: String]
    let altTitles: [[String: String]]
    let description: [String: String]
    let status: String
    let year: Int?
    let contentRating: String
    let tags: [Tag]
    let state: String
    let createdAt: String
    let updatedAt: String
    let lastChapter: String?
}

struct Tag: Codable, Identifiable {
    let id: String
    let attributes: TagAttributes
}

struct TagAttributes: Codable {
    let name: [String: String]
    let group: String
}

// MARK: - Relationship
struct Relationship: Codable {
    let id: String
    let type: String
    let attributes: RelationshipAttributes?
}

struct RelationshipAttributes: Codable {
    // Basic catch-all attributes
    let fileName: String?
}

// MARK: - Chapter Models
struct Chapter: Codable, Identifiable {
    let id: String
    let attributes: ChapterAttributes
    let relationships: [Relationship]
}

struct ChapterAttributes: Codable {
    let title: String?
    let volume: String?
    let chapter: String?
    let pages: Int
    let translatedLanguage: String
    let publishAt: String
}

// MARK: - AtHome Server Response
struct AtHomeResponse: Codable {
    let baseUrl: String
    let chapter: ChapterData
}

struct ChapterData: Codable {
    let hash: String
    let data: [String]
    let dataSaver: [String]
}
