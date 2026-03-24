import Foundation
import Combine
import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var isDataSaverEnabled: Bool {
        didSet { UserDefaults.standard.set(isDataSaverEnabled, forKey: "isDataSaverEnabled") }
    }
    
    @Published var readingMode: ReadingMode {
        didSet { UserDefaults.standard.set(readingMode.rawValue, forKey: "readingMode") }
    }
    
    @Published var appTheme: AppTheme {
        didSet { UserDefaults.standard.set(appTheme.rawValue, forKey: "appTheme") }
    }
    
    enum ReadingMode: String {
        case vertical = "Vertical"
        case horizontal = "Horizontal"
    }
    
    enum AppTheme: String, CaseIterable {
        case system = "Hệ thống"
        case light = "Sáng"
        case dark = "Tối"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    
    private init() {
        self.isDataSaverEnabled = UserDefaults.standard.bool(forKey: "isDataSaverEnabled")
        if let mode = UserDefaults.standard.string(forKey: "readingMode"),
           let readingMode = ReadingMode(rawValue: mode) {
            self.readingMode = readingMode
        } else {
            self.readingMode = .vertical
        }
        
        if let theme = UserDefaults.standard.string(forKey: "appTheme"),
           let appTheme = AppTheme(rawValue: theme) {
            self.appTheme = appTheme
        } else {
            self.appTheme = .system
        }
    }
}
