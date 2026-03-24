import SwiftUI
import SwiftData

struct StatsView: View {
    @Query var history: [ReadingHistory]
    @Query(sort: \DailyReadingStat.date, order: .reverse) var dailyStats: [DailyReadingStat]
    
    var totalTime: Double {
        history.reduce(0) { $0 + $1.readingTime }
    }
    
    var totalPages: Int {
        history.reduce(0) { $0 + $1.pagesRead }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Cards
                    HStack(spacing: 16) {
                        StatCard(title: "Thời gian đọc", value: formatTime(totalTime), icon: "clock.fill", color: .blue)
                        StatCard(title: "Số trang", value: "\(totalPages)", icon: "book.fill", color: .green)
                    }
                    .padding(.horizontal)
                    
                    // Weekly Activity Chart
                    WeeklyActivityChart(stats: Array(dailyStats.prefix(7)))
                        .padding(.horizontal)
                    
                    // Detailed List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Chi tiết theo truyện")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(history.sorted(by: { $0.readingTime > $1.readingTime })) { record in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(record.mangaTitle)
                                        .font(.subheadline)
                                        .bold()
                                    Text("\(formatTime(record.readingTime)) • \(record.pagesRead) trang")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                // Progress bar or similar could go here
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Thống kê")
        }
    }
    
    func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        if mins < 60 {
            return "\(mins) phút"
        } else {
            let hours = mins / 60
            let remainingMins = mins % 60
            return "\(hours)h \(remainingMins)m"
        }
    }
}

struct WeeklyActivityChart: View {
    let stats: [DailyReadingStat]
    
    var maxSeconds: Double {
        max(stats.map { $0.secondsRead }.max() ?? 60, 60)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hoạt động 7 ngày qua")
                .font(.headline)
            
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(0..<7) { index in
                    let date = Calendar.current.date(byAdding: .day, value: -index, to: Date())!
                    let stat = stats.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
                    let height = CGFloat((stat?.secondsRead ?? 0) / maxSeconds) * 120
                    
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(width: 25, height: max(height, 4))
                        
                        Text(dayLabel(for: date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title3)
                    .bold()
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}
