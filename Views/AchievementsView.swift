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
                                        Text("\(record.value, specifier: "%.1f")")
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
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample user profile for previewing
        var sampleProfile = UserProfile()
        sampleProfile.achievements = [
            Achievement(title: "First Workout", description: "Completed your first workout.", iconName: "star.fill", isEarned: true),
            Achievement(title: "Heavy Lifter", description: "Lifted over 5000 lbs in a single workout.", iconName: "scalemass.fill", isEarned: true)
        ]
        sampleProfile.personalRecords = [
            PersonalRecord(exerciseName: "Bench Press", recordType: .oneRepMax, value: 225.0, date: Date()),
            PersonalRecord(exerciseName: "Bench Press", recordType: .maxWeight, value: 205.0, date: Date()),
            PersonalRecord(exerciseName: "Squat", recordType: .oneRepMax, value: 315.0, date: Date())
        ]

        return AchievementsView(userProfile: sampleProfile)
    }
}
