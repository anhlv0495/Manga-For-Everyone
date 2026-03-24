import Foundation

enum APIConstants {
    static let baseURL = URL(string: "https://api.mangadex.org")!
    static let uploadsURL = URL(string: "https://uploads.mangadex.org")!
    
    enum Endpoint {
        static let manga = "/manga"
        static let chapter = "/chapter"
        static let cover = "/cover"
        static let author = "/author"
        static let atHomeServer = "/at-home/server"
    }
}
