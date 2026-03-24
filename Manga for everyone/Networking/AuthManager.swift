import Foundation
import SwiftUI
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    @Published var isAuthenticated = false
    @Published var username: String?
    
    private let tokenKey = "mangadex_auth_token"
    private let refreshTokenKey = "mangadex_refresh_token"
    
    private init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let _ = UserDefaults.standard.string(forKey: tokenKey) {
            isAuthenticated = true
            // In a real app, you'd verify the token or fetch user profile
            username = "MangaDex User" 
        } else {
            isAuthenticated = false
            username = nil
        }
    }
    
    func login(clientId: String, clientSecret: String) async -> Bool {
        // Đây là bản mô phỏng luồng OAuth2 của MangaDex
        // Thực tế cần gọi endpoint /auth/login hoặc exchange code
        
        // Giả lập delay mạng
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        if !clientId.isEmpty && !clientSecret.isEmpty {
            UserDefaults.standard.set("mock_access_token", forKey: tokenKey)
            UserDefaults.standard.set("mock_refresh_token", forKey: refreshTokenKey)
            DispatchQueue.main.async {
                self.isAuthenticated = true
                self.username = "MangaDex User"
            }
            return true
        }
        return false
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        isAuthenticated = false
        username = nil
    }
    
    func getAuthHeader() -> [String: String]? {
        if let token = UserDefaults.standard.string(forKey: tokenKey) {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }
}
