//
//  Manga_for_everyoneApp.swift
//  Manga for everyone
//
//  Created by Anh Lê Việt on 3/24/26.
//

import SwiftUI
import SwiftData

@main
struct Manga_for_everyoneApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(for: [FavoriteManga.self, ReadingHistory.self, DownloadedChapter.self, DailyReadingStat.self])
        }
    }
}
