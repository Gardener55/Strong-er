import SwiftUI

struct AchievementsView: View {
    @Binding var userProfile: UserProfile
    @State private var showAllEarned = false
    @State private var showAllUnearned = false
    @State private var showAllPRs = false

    private var earnedAchievements: [Achievement] {
        userProfile.achievements.filter { $0.isEarned }.sorted { $0.earnedDate ?? Date() > $1.earnedDate ?? Date() }
    }

    private var unearnedAchievements: [Achievement] {
        userProfile.achievements.filter { !$0.isEarned }
    }

    private var pinnedRecords: [String: [PersonalRecord]] {
        Dictionary(grouping: userProfile.personalRecords, by: { $0.exerciseName })
            .filter { userProfile.watchedExercises.contains($0.key) }
    }

    private var unpinnedRecords: [String: [PersonalRecord]] {
        Dictionary(grouping: userProfile.personalRecords, by: { $0.exerciseName })
            .filter { !userProfile.watchedExercises.contains($0.key) }
    }

    var body: some View {
        List {
            Section(header: Text("Achievements Earned (\(earnedAchievements.count))")) {
                if earnedAchievements.isEmpty {
                    Text("No achievements yet. Keep working out!")
                } else {
                    let displayedEarned = showAllEarned ? earnedAchievements : Array(earnedAchievements.prefix(5))
                    ForEach(displayedEarned) { achievement in
                        HStack {
                            Image(systemName: achievement.iconName)
                                .font(.title)
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading) {
                                Text(achievement.title).font(.headline)
                                Text(achievement.description).font(.subheadline).foregroundColor(.secondary)
                                if let date = achievement.earnedDate {
                                    Text("Earned: \(date, formatter: itemFormatter)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    if earnedAchievements.count > 5 {
                        Button(action: {
                            withAnimation {
                                showAllEarned.toggle()
                            }
                        }) {
                            Text(showAllEarned ? "Show Less" : "Show More...")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }

            if !pinnedRecords.isEmpty {
                Section(header: Text("Pinned Personal Records")) {
                    ForEach(pinnedRecords.keys.sorted(), id: \.self) { exerciseName in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(exerciseName).font(.headline)
                                Spacer()
                                Button(action: { togglePin(for: exerciseName) }) {
                                    Image(systemName: "pin.fill").foregroundColor(.accentColor)
                                }
                            }
                            ForEach(pinnedRecords[exerciseName]!) { record in
                                HStack {
                                    Text(record.recordType.rawValue).font(.subheadline)
                                    Spacer()
                                    Text(formattedValue(for: record, unit: userProfile.weightUnit)).fontWeight(.semibold)
                                }
                            }
                        }.padding(.vertical, 4)
                    }
                }
            }

            Section(header: Text(pinnedRecords.isEmpty ? "Personal Records (\(unpinnedRecords.count))" : "Other Personal Records (\(unpinnedRecords.count))")) {
                if unpinnedRecords.isEmpty && pinnedRecords.isEmpty {
                    Text("No personal records yet. Let's lift!")
                } else if unpinnedRecords.isEmpty && !pinnedRecords.isEmpty {
                    Text("All records are pinned.")
                } else {
                    let unpinnedKeys = unpinnedRecords.keys.sorted()
                    let displayedKeys = showAllPRs ? unpinnedKeys : Array(unpinnedKeys.prefix(5))

                    ForEach(displayedKeys, id: \.self) { exerciseName in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(exerciseName).font(.headline)
                                Spacer()
                                Button(action: { togglePin(for: exerciseName) }) {
                                    Image(systemName: "pin").foregroundColor(.accentColor)
                                }
                            }
                            ForEach(unpinnedRecords[exerciseName]!) { record in
                                HStack {
                                    Text(record.recordType.rawValue).font(.subheadline)
                                    Spacer()
                                    Text(formattedValue(for: record, unit: userProfile.weightUnit)).fontWeight(.semibold)
                                }
                            }
                        }.padding(.vertical, 4)
                    }

                    if unpinnedRecords.count > 5 {
                        Button(action: {
                            withAnimation {
                                showAllPRs.toggle()
                            }
                        }) {
                            Text(showAllPRs ? "Show Less" : "Show More...")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
            }

            Section(header: Text("Achievements to Unlock (\(unearnedAchievements.count))")) {
                let displayedUnearned = showAllUnearned ? unearnedAchievements : Array(unearnedAchievements.prefix(5))
                ForEach(displayedUnearned) { achievement in
                    HStack {
                        Image(systemName: achievement.iconName)
                            .font(.title)
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text(achievement.title).font(.headline)
                            Text(achievement.description).font(.subheadline).foregroundColor(.secondary)
                        }
                    }
                }
                if unearnedAchievements.count > 5 {
                    Button(action: {
                        withAnimation {
                            showAllUnearned.toggle()
                        }
                    }) {
                        Text(showAllUnearned ? "Show Less" : "Show More...")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .navigationTitle("My Achievements")
    }

    private func togglePin(for exerciseName: String) {
        if let index = userProfile.watchedExercises.firstIndex(of: exerciseName) {
            userProfile.watchedExercises.remove(at: index)
        } else {
            userProfile.watchedExercises.append(exerciseName)
        }
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

    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample user profile for previewing
        @State var sampleProfile = UserProfile(
            personalRecords: [
                PersonalRecord(exerciseName: "Bench Press", recordType: .oneRepMax, value: 100.0, date: Date()),
                PersonalRecord(exerciseName: "Squat", recordType: .maxWeight, value: 120.0, date: Date())
            ],
            achievements: [
                Achievement(title: "First Workout", description: "Completed your first workout.", iconName: "star.fill", isEarned: true, earnedDate: Date()),
                Achievement(title: "Workout Warrior", description: "Completed 10 workouts.", iconName: "flame.fill", isEarned: false)
            ],
            watchedExercises: ["Bench Press"]
        )

        return NavigationView {
            AchievementsView(userProfile: $sampleProfile)
        }
    }
}
