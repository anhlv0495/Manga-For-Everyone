import Foundation

class MangaDexClient {
    static let shared = MangaDexClient()
    private let session = URLSession.shared
    private let decoder: JSONDecoder
    
    private init() {
        decoder = JSONDecoder()
    }
    
    // MARK: - API Calls
    
    /// Tìm kiếm truyện hoặc lấy danh sách truyện mới/phổ biến
    func fetchMangaList(
        limit: Int = 20,
        offset: Int = 0,
        title: String? = nil,
        includedTags: [String] = [],
        status: [String] = [],
        demographic: [String] = [],
        order: [String: String] = ["latestUploadedChapter": "desc"],
        contentRating: [String] = ["safe", "suggestive"]
    ) async throws -> [Manga] {
        var components = URLComponents(url: APIConstants.baseURL.appendingPathComponent(APIConstants.Endpoint.manga), resolvingAgainstBaseURL: true)!
        
        var queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "includes[]", value: "cover_art"),
            URLQueryItem(name: "includes[]", value: "author")
        ]
        
        contentRating.forEach { queryItems.append(URLQueryItem(name: "contentRating[]", value: $0)) }
        includedTags.forEach { queryItems.append(URLQueryItem(name: "includedTags[]", value: $0)) }
        status.forEach { queryItems.append(URLQueryItem(name: "status[]", value: $0)) }
        demographic.forEach { queryItems.append(URLQueryItem(name: "publicationDemographic[]", value: $0)) }
        
        order.forEach { key, value in
            queryItems.append(URLQueryItem(name: "order[\(key)]", value: value))
        }
        
        if let title = title, !title.isEmpty {
            queryItems.append(URLQueryItem(name: "title", value: title))
        }
        
        // Sắp xếp mặc định: Truyện mới cập nhật lên đầu
        queryItems.append(URLQueryItem(name: "order[latestUploadedChapter]", value: "desc"))
        
        components.queryItems = queryItems
        
        guard let url = components.url else { throw NetworkError.invalidURL }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.noData }
        guard (200...299).contains(httpResponse.statusCode) else { throw NetworkError.serverError(httpResponse.statusCode) }
        
        do {
            let apiResponse = try decoder.decode(APIListResponse<Manga>.self, from: data)
            return apiResponse.data
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Lấy danh sách chapter của một bộ truyện
    func fetchChapters(
        mangaId: String, 
        offset: Int = 0, 
        translatedLanguage: [String] = ["vi", "en"],
        order: [String: String] = ["chapter": "asc"]
    ) async throws -> [Chapter] {
        var components = URLComponents(url: APIConstants.baseURL.appendingPathComponent(APIConstants.Endpoint.manga).appendingPathComponent(mangaId).appendingPathComponent("feed"), resolvingAgainstBaseURL: true)!
        
        var queryItems = [
            URLQueryItem(name: "limit", value: "100"),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "includes[]", value: "scanlation_group")
        ]
        
        order.forEach { key, value in
            queryItems.append(URLQueryItem(name: "order[\(key)]", value: value))
        }
        
        translatedLanguage.forEach { queryItems.append(URLQueryItem(name: "translatedLanguage[]", value: $0)) }
        
        components.queryItems = queryItems
        
        guard let url = components.url else { throw NetworkError.invalidURL }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.noData }
        guard (200...299).contains(httpResponse.statusCode) else { throw NetworkError.serverError(httpResponse.statusCode) }
        
        do {
            let apiResponse = try decoder.decode(APIListResponse<Chapter>.self, from: data)
            return apiResponse.data
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Lấy thông tin máy chủ ảnh cho một chapter
    func fetchAtHomeServer(chapterId: String) async throws -> AtHomeResponse {
        let url = APIConstants.baseURL
            .appendingPathComponent(APIConstants.Endpoint.atHomeServer)
            .appendingPathComponent(chapterId)
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.noData }
        guard (200...299).contains(httpResponse.statusCode) else { throw NetworkError.serverError(httpResponse.statusCode) }
        
        do {
            return try decoder.decode(AtHomeResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Lấy danh sách toàn bộ tag (thể loại)
    func fetchTags() async throws -> [Tag] {
        let url = APIConstants.baseURL.appendingPathComponent("/manga/tag")
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.noData }
        guard (200...299).contains(httpResponse.statusCode) else { throw NetworkError.serverError(httpResponse.statusCode) }
        
        do {
            let apiResponse = try decoder.decode(APIResponse<[Tag]>.self, from: data)
            return apiResponse.data
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func fetchManga(id: String) async throws -> Manga {
        var components = URLComponents(url: APIConstants.baseURL.appendingPathComponent(APIConstants.Endpoint.manga).appendingPathComponent(id), resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "includes[]", value: "cover_art"),
            URLQueryItem(name: "includes[]", value: "author")
        ]
        
        guard let url = components.url else { throw NetworkError.invalidURL }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.noData }
        guard (200...299).contains(httpResponse.statusCode) else { throw NetworkError.serverError(httpResponse.statusCode) }
        
        do {
            let apiResponse = try decoder.decode(APIResponse<Manga>.self, from: data)
            return apiResponse.data
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Đánh dấu chương đã đọc trên server (Xác thực)
    func markChapterAsRead(chapterId: String) async throws {
        let url = APIConstants.baseURL.appendingPathComponent("/manga/chapter/\(chapterId)/read")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let headers = AuthManager.shared.getAuthHeader() {
            headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        } else {
            return // Không đăng nhập thì bỏ qua
        }
        
        _ = try await session.data(for: request)
    }
    
    /// Lấy danh sách truyện liên quan
    func fetchRelatedManga(mangaId: String) async throws -> [Manga] {
        // MangaDex dùng relationships để chỉ định truyện liên quan
        // Chúng ta lấy thông tin manga và tìm các mối quan hệ "manga"
        let manga = try await fetchManga(id: mangaId)
        let relatedIds = manga.relationships.filter { $0.type == "manga" && $0.id != mangaId }.map { $0.id }
        
        if relatedIds.isEmpty { return [] }
        
        // Fetch chi tiết cho các truyện liên quan (giới hạn 5 truyện đầu)
        var relatedManga: [Manga] = []
        for id in relatedIds.prefix(5) {
            if let m = try? await fetchManga(id: id) {
                relatedManga.append(m)
            }
        }
        return relatedManga
    }
    
    func fetchChapter(id: String) async throws -> Chapter {
        let url = APIConstants.baseURL.appendingPathComponent(APIConstants.Endpoint.manga).appendingPathComponent("chapter").appendingPathComponent(id)
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.noData }
        guard (200...299).contains(httpResponse.statusCode) else { throw NetworkError.serverError(httpResponse.statusCode) }
        
        do {
            let apiResponse = try decoder.decode(APIResponse<Chapter>.self, from: data)
            return apiResponse.data
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Lấy danh sách truyện đang theo dõi (Yêu cầu đăng nhập)
    func fetchFollowedManga() async throws -> [Manga] {
        var components = URLComponents(url: APIConstants.baseURL.appendingPathComponent("/user/follows/manga"), resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "limit", value: "100"),
            URLQueryItem(name: "includes[]", value: "cover_art")
        ]
        
        guard let url = components.url else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        if let headers = AuthManager.shared.getAuthHeader() {
            headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        } else {
            throw NetworkError.noData // Hoặc lỗi Unauthorized
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.noData }
        guard (200...299).contains(httpResponse.statusCode) else { throw NetworkError.serverError(httpResponse.statusCode) }
        
        do {
            let apiResponse = try decoder.decode(APIListResponse<Manga>.self, from: data)
            return apiResponse.data
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

// MARK: - Helpers
extension MangaDexClient {
    func getCoverURL(manga: Manga) -> URL? {
        if let coverRel = manga.relationships.first(where: { $0.type == "cover_art" }),
           let fileName = coverRel.attributes?.fileName {
            return APIConstants.uploadsURL
                .appendingPathComponent("covers")
                .appendingPathComponent(manga.id)
                .appendingPathComponent(fileName)
        }
        return nil
    }
    
    func getPageURLs(atHome: AtHomeResponse, useDataSaver: Bool) -> [URL] {
        let host = atHome.baseUrl
        let hash = atHome.chapter.hash
        let pages = useDataSaver ? atHome.chapter.dataSaver : atHome.chapter.data
        let quality = useDataSaver ? "data-saver" : "data"
        
        return pages.compactMap { page in
            URL(string: "\(host)/\(quality)/\(hash)/\(page)")
        }
    }
}
