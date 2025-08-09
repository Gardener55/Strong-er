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
        let value = record.value
        let unitString = unit.rawValue

        // The value is stored in the user's preferred unit, so no conversion is needed.
        // We just need to format it and append the correct unit string.
        return String(format: "%.1f %@", value, unitString)
    }
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample user profile for previewing in KG
        var sampleProfileKg = UserProfile()
        sampleProfileKg.weightUnit = .kilograms
        sampleProfileKg.achievements = [
            Achievement(title: "First Workout", description: "Completed your first workout.", iconName: "star.fill", isEarned: true)
        ]
        sampleProfileKg.personalRecords = [
            PersonalRecord(exerciseName: "Bench Press", recordType: .oneRepMax, value: 100.0, date: Date()),
            PersonalRecord(exerciseName: "Squat", recordType: .maxWeight, value: 120.0, date: Date())
        ]

        // Create a sample user profile for previewing in LBS
        var sampleProfileLbs = UserProfile()
        sampleProfileLbs.weightUnit = .pounds
        sampleProfileLbs.personalRecords = [
            // Assuming this value was entered as 220.5 lbs
            PersonalRecord(exerciseName: "Bench Press", recordType: .oneRepMax, value: 220.5, date: Date()),
            PersonalRecord(exerciseName: "Squat", recordType: .maxWeight, value: 264.6, date: Date())
        ]

        return Group {
            AchievementsView(userProfile: sampleProfileKg)
                .previewDisplayName("KG View")
            AchievementsView(userProfile: sampleProfileLbs)
                .previewDisplayName("LBS View")
        }
    }
}
