import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case unknown(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: return "Địa chỉ URL không hợp lệ."
        case .noData: return "Không có dữ liệu trả về từ máy chủ."
        case .decodingError(let error): return "Lỗi giải mã dữ liệu: \(error.localizedDescription)"
        case .serverError(let code): return "Lỗi máy chủ: \(code)"
        case .unknown(let error): return "Lỗi không xác định: \(error.localizedDescription)"
        }
    }
}
