import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var descriptionTemplate: String
    var iconName: String
    var isEarned: Bool = false
    var earnedDate: Date?

    // For weight-based achievements
    var goalValue: Double?
    var goalUnit: UserProfile.WeightUnit?

    enum CodingKeys: String, CodingKey {
        case id, title, descriptionTemplate, iconName, isEarned, earnedDate, goalValue, goalUnit
    }

    func description(for displayUnit: UserProfile.WeightUnit) -> String {
        guard let goalValue = goalValue, let goalUnit = goalUnit else {
            return descriptionTemplate
        }

        let targetValue: Double
        let unitString: String

        if displayUnit == goalUnit {
            targetValue = goalValue
        } else {
            if displayUnit == .pounds {
                // goalUnit must be .kilograms
                targetValue = goalValue * 2.20462
            } else {
                // displayUnit is .kilograms, goalUnit must be .pounds
                targetValue = goalValue / 2.20462
            }
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formattedValue = formatter.string(from: NSNumber(value: targetValue)) ?? "\(targetValue)"

        unitString = displayUnit.rawValue

        return descriptionTemplate
            .replacingOccurrences(of: "{value}", with: formattedValue)
            .replacingOccurrences(of: "{unit}", with: unitString)
    }
}
