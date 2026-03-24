import SwiftUI

struct FilterSheet: View {
    @Binding var selectedStatus: [String]
    @Binding var selectedDemographics: [String]
    @Binding var selectedOrder: String
    
    let statuses = ["ongoing", "completed", "hiatus", "cancelled"]
    let demographics = ["shounen", "shoujo", "seinen", "josei"]
    let orders = [
        "latestUploadedChapter": "Mới cập nhật",
        "rating": "Đánh giá cao",
        "followedCount": "Theo dõi nhiều",
        "title": "Tên A-Z"
    ]
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tình trạng")) {
                    ForEach(statuses, id: \.self) { status in
                        Toggle(status.capitalized, isOn: Binding(
                            get: { selectedStatus.contains(status) },
                            set: { isOn in
                                if isOn { selectedStatus.append(status) }
                                else { selectedStatus.removeAll { $0 == status } }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Đối tượng")) {
                    ForEach(demographics, id: \.self) { demo in
                        Toggle(demo.capitalized, isOn: Binding(
                            get: { selectedDemographics.contains(demo) },
                            set: { isOn in
                                if isOn { selectedDemographics.append(demo) }
                                else { selectedDemographics.removeAll { $0 == demo } }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Sắp xếp theo")) {
                    Picker("Sắp xếp", selection: $selectedOrder) {
                        ForEach(orders.keys.sorted(), id: \.self) { key in
                            Text(orders[key] ?? "").tag(key)
                        }
                    }
                }
            }
            .navigationTitle("Bộ lọc nâng cao")
            .navigationBarItems(trailing: Button("Xong") { dismiss() })
        }
    }
}
