import SwiftUI

struct LoginView: View {
    @State private var clientId = ""
    @State private var clientSecret = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section(header: Text("Thông tin MangaDex Client")) {
                TextField("Client ID", text: $clientId)
                SecureField("Client Secret", text: $clientSecret)
            }
            
            Section {
                Button(action: performLogin) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text("Đăng nhập")
                            .frame(maxWidth: .infinity)
                            .bold()
                    }
                }
                .disabled(clientId.isEmpty || clientSecret.isEmpty || isLoading)
            }
            
            Section(footer: Text("Vui lòng truy cập MangaDex settings để lấy Client ID và Secret của bạn.")) {
                Link("Lấy Client ID ở đâu?", destination: URL(string: "https://mangadex.org/settings")!)
                    .font(.caption)
            }
            
            if let error = errorMessage {
                Section {
                    Text(error).foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Kết nối tài khoản")
    }
    
    func performLogin() {
        isLoading = true
        Task {
            let success = await AuthManager.shared.login(clientId: clientId, clientSecret: clientSecret)
            if success {
                dismiss()
            } else {
                errorMessage = "Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin."
            }
            isLoading = false
        }
    }
}
