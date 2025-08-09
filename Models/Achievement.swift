import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var description: String
    var iconName: String
    var isEarned: Bool = false
    var earnedDate: Date?
}
