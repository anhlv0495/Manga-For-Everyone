# MangaVN - Premium Manga Reader for iOS

MangaVN is a modern, high-performance manga reading application built entirely with SwiftUI, powered by the MangaDex API. It focuses on a premium user experience with deep synchronization and personalization features.

![MangaVN Banner](https://via.placeholder.com/800x400?text=MangaVN+Premium+Reader)

## 🌟 Key Features

### 📖 Reader Experience
- **Multi-Reading Mode**: Seamless support for both Vertical Scroll (Webtoon) and horizontal Page-turn (Manga).
- **Pro Customization**: 
  - Blue light filter for eye protection.
  - Adjustable Page Gap for vertical reading.
- **Auto-next**: Automatically finds and pre-fetches the next chapter for an uninterrupted flow.
- **Data Saver**: Integrated MangaDex data-saver mode for efficient mobile data usage.

### ☁️ Accounts & Sync
- **MangaDex Authentication**: Log in to sync your "Followed" list directly from the website.
- **Reading Markers**: Automatically syncs your reading progress to MangaDex servers, allowing a seamless transition between web and app.

### 📥 Offline & Library
- **Offline Reading**: Download chapters to read anytime, anywhere without an internet connection.
- **Smart Library**: Intuitively manage Favorites, History, and Downloaded chapters.

### 📊 Statistics & Personalization
- **Reading Stats**: Track reading duration, page counts, and view your 7-day activity chart.
- **Light/Dark Mode**: Adaptive UI that follows system settings or manual preference.
- **Featured Carousel**: Discover trending manga with a sleek glassmorphism carousel.

## 🛠 Technology Stack

- **Interface**: SwiftUI
- **Data Persistence**: SwiftData (Local SQL Database)
- **Networking**: URLSession, Async/Await
- **Architecture**: MVVM
- **Database**: MangaDex API v5

## 🚀 Getting Started

1. **Clone the project**:
   ```bash
   git clone https://github.com/yourusername/manga-vn.git
   ```
2. **Open in Xcode**: Open the `Manga for everyone.xcodeproj` file.
3. **Build & Run**: Select a simulator or physical device and press `Cmd + R`.

*Note: Requires iOS 17.0+ for SwiftData support.*

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.

---
*Developed by [Anh Le Viet](https://github.com/anhleviet) with 💖 for the Manga community.*
