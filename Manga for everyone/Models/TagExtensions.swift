import Foundation

extension Tag {
    var displayName: String {
        attributes.name["vi"] ?? attributes.name["en"] ?? attributes.name.values.first ?? "Unknown"
    }
}
