import SwiftUI

struct AchievementsView: View {
    let userProfile: UserProfile

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Achievements")) {
                    if userProfile.achievements.filter({ $0.isEarned }).isEmpty {
                        Text("No achievements yet. Keep working out!")
                    } else {
                        ForEach(userProfile.achievements.filter { $0.isEarned }) { achievement in
                            HStack {
                                Image(systemName: achievement.iconName)
                                    .font(.title)
                                    .foregroundColor(.yellow)
                                VStack(alignment: .leading) {
                                    Text(achievement.title).font(.headline)
                                    Text(achievement.description).font(.subheadline)
                                }
                            }
                        }
                    }
                }

                Section(header: Text("Personal Records")) {
                    if userProfile.personalRecords.isEmpty {
                        Text("No personal records yet. Let's lift!")
                    } else {
                        ForEach(groupedRecords.keys.sorted(), id: \.self) { exerciseName in
                            VStack(alignment: .leading) {
                                Text(exerciseName).font(.headline)
                                ForEach(groupedRecords[exerciseName]!) { record in
                                    HStack {
                                        Text(record.recordType.rawValue)
                                        Spacer()
                                        Text(formattedValue(for: record, unit: userProfile.weightUnit))
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Achievements")
        }
    }

    private var groupedRecords: [String: [PersonalRecord]] {
        Dictionary(grouping: userProfile.personalRecords, by: { $0.exerciseName })
    }

    private func formattedValue(for record: PersonalRecord, unit: UserProfile.WeightUnit) -> String {
        let storedValueKg = record.value

        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", storedValueKg)
        case .pounds:
            let convertedValueLbs = storedValueKg * 2.20462
            return String(format: "%.1f lbs", convertedValueLbs)
        }
    }
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample user profile for previewing
        // All PRs are stored in KG, regardless of the user's preference.
        var sampleProfile = UserProfile()
        sampleProfile.achievements = [
            Achievement(title: "First Workout", description: "Completed your first workout.", iconName: "star.fill", isEarned: true)
        ]
        sampleProfile.personalRecords = [
            PersonalRecord(exerciseName: "Bench Press", recordType: .oneRepMax, value: 100.0, date: Date()), // 100.0 kg
            PersonalRecord(exerciseName: "Squat", recordType: .maxWeight, value: 120.0, date: Date())      // 120.0 kg
        ]

        // Create a KG view
        var kgProfile = sampleProfile
        kgProfile.weightUnit = .kilograms

        // Create an LBS view
        var lbsProfile = sampleProfile
        lbsProfile.weightUnit = .pounds

        return Group {
            AchievementsView(userProfile: kgProfile)
                .previewDisplayName("KG View")

            AchievementsView(userProfile: lbsProfile)
                .previewDisplayName("LBS View")
        }
    }
}
