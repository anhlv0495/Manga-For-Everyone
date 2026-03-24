import SwiftUI

struct MainTabView: View {
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Khám phá", systemImage: "house")
                }
            
            SearchView()
                .tabItem {
                    Label("Tìm kiếm", systemImage: "magnifyingglass")
                }
            
            LibraryView()
                .tabItem {
                    Label("Thư viện", systemImage: "books.vertical.fill")
                }
            
            StatsView()
                .tabItem {
                    Label("Thống kê", systemImage: "chart.bar.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Cài đặt", systemImage: "gear")
                }
        }
        .accentColor(.orange)
        .preferredColorScheme(settings.appTheme.colorScheme)
    }
}

struct SettingsView: View {
    @ObservedObject var settings = AppSettings.shared
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tài khoản MangaDex")) {
                    if AuthManager.shared.isAuthenticated {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.orange)
                            VStack(alignment: .leading) {
                                Text(AuthManager.shared.username ?? "Người dùng")
                                    .font(.headline)
                                Text("Đã kết nối")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            Spacer()
                            Button("Đăng xuất") {
                                AuthManager.shared.logout()
                            }
                            .foregroundColor(.red)
                        }
                    } else {
                        NavigationLink(destination: LoginView()) {
                            Label("Đăng nhập MangaDex", systemImage: "arrow.right.square")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Section(header: Text("Chế độ đọc")) {
                    Picker("Giao diện", selection: $settings.appTheme) {
                        ForEach(AppSettings.AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    
                    Picker("Kiểu lật trang", selection: $settings.readingMode) {
                        Text("Cuộn dọc (Webtoon)").tag(AppSettings.ReadingMode.vertical)
                        Text("Lật ngang (Manga)").tag(AppSettings.ReadingMode.horizontal)
                    }
                    
                    if settings.readingMode == .vertical {
                        VStack(alignment: .leading) {
                            Text("Khoảng cách trang: \(Int(settings.pageGap))px")
                            Slider(value: $settings.pageGap, in: 0...20, step: 1)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Lọc ánh sáng xanh: \(Int(settings.blueLightFilter * 200))%")
                        Slider(value: $settings.blueLightFilter, in: 0...0.5)
                    }
                }
                
                Section(header: Text("Dữ liệu")) {
                    Toggle("Tiết kiệm dữ liệu (DataSaver)", isOn: $settings.isDataSaverEnabled)
                }
                
                Section(header: Text("Thông tin")) {
                    HStack {
                        Text("Phiên bản")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Cài đặt")
        }
    }
}
