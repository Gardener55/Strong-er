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
            // Earned Achievements Section
            Section(header: Text("Achievements Earned (\(earnedAchievements.count))")) {
                let displayedData = showAllEarned ? earnedAchievements : Array(earnedAchievements.prefix(5))
                ForEach(displayedData) { achievement in
                    AchievementRow(achievement: achievement, isEarned: true)
                }
                if earnedAchievements.count > 5 {
                    ShowMoreButton(isExpanded: $showAllEarned)
                }
            }

            // Pinned PRs Section
            if !pinnedRecords.isEmpty {
                Section(header: Text("Pinned Personal Records")) {
                    ForEach(pinnedRecords.keys.sorted(), id: \.self) { exerciseName in
                        PRRow(userProfile: $userProfile, exerciseName: exerciseName, records: pinnedRecords[exerciseName]!)
                    }
                }
            }

            // Other PRs Section
            Section(header: Text(pinnedRecords.isEmpty ? "Personal Records" : "Other Personal Records")) {
                let keys = unpinnedRecords.keys.sorted()
                let displayedKeys = showAllPRs ? keys : Array(keys.prefix(5))

                if keys.isEmpty && pinnedRecords.isEmpty {
                    Text("No personal records yet. Let's lift!")
                } else if keys.isEmpty {
                    Text("All records are pinned.")
                } else {
                    ForEach(displayedKeys, id: \.self) { exerciseName in
                        PRRow(userProfile: $userProfile, exerciseName: exerciseName, records: unpinnedRecords[exerciseName]!)
                    }
                    if keys.count > 5 {
                        ShowMoreButton(isExpanded: $showAllPRs)
                    }
                }
            }

            // Unearned Achievements Section
            Section(header: Text("Achievements to Unlock (\(unearnedAchievements.count))")) {
                let displayedData = showAllUnearned ? unearnedAchievements : Array(unearnedAchievements.prefix(5))
                ForEach(displayedData) { achievement in
                    AchievementRow(achievement: achievement, isEarned: false)
                }
                if unearnedAchievements.count > 5 {
                    ShowMoreButton(isExpanded: $showAllUnearned)
                }
            }
        }
        .navigationTitle("My Achievements")
    }

    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

// MARK: - Subviews

private struct AchievementRow: View {
    let achievement: Achievement
    let isEarned: Bool

    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        HStack {
            Image(systemName: achievement.iconName)
                .font(.title)
                .foregroundColor(isEarned ? .yellow : .gray)
            VStack(alignment: .leading) {
                Text(achievement.title).font(.headline)
                Text(achievement.description).font(.subheadline).foregroundColor(.secondary)
                if let date = achievement.earnedDate, isEarned {
                    Text("Earned: \(date, formatter: itemFormatter)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

private struct PRRow: View {
    @Binding var userProfile: UserProfile
    let exerciseName: String
    let records: [PersonalRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exerciseName).font(.headline)
                Spacer()
                Button(action: { togglePin(for: exerciseName) }) {
                    Image(systemName: userProfile.watchedExercises.contains(exerciseName) ? "pin.fill" : "pin")
                        .foregroundColor(.accentColor)
                }
            }
            ForEach(records) { record in
                HStack {
                    Text(record.recordType.rawValue).font(.subheadline)
                    Spacer()
                    Text(formattedValue(for: record, unit: userProfile.weightUnit)).fontWeight(.semibold)
                }
            }
        }.padding(.vertical, 4)
    }

    private func togglePin(for exerciseName: String) {
        if let index = userProfile.watchedExercises.firstIndex(of: exerciseName) {
            userProfile.watchedExercises.remove(at: index)
        } else {
            userProfile.watchedExercises.append(exerciseName)
        }
    }

    private func formattedValue(for record: PersonalRecord, unit: UserProfile.WeightUnit) -> String {
        // This is a temporary fix. The root cause is likely that PersonalRecord.value is not being
        // consistently stored in KG. This function now assumes the stored value is in the user's
        // currently selected unit, which should fix the immediate display issue.
        let value = record.value

        switch unit {
        case .kilograms:
            return String(format: "%.1f kg", value)
        case .pounds:
            return String(format: "%.1f lbs", value)
        }
    }
}

private struct ShowMoreButton: View {
    @Binding var isExpanded: Bool

    var body: some View {
        Button(action: {
            withAnimation {
                isExpanded.toggle()
            }
        }) {
            Text(isExpanded ? "Show Less" : "Show More...")
                .foregroundColor(.accentColor)
        }
    }
}

// MARK: - Preview

struct AchievementsView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a sample user profile for previewing
        @State var sampleProfile = UserProfile(
            personalRecords: [
                PersonalRecord(exerciseName: "Bench Press", recordType: .oneRepMax, value: 100.0, date: Date()), // 100 kg
                PersonalRecord(exerciseName: "Squat", recordType: .maxWeight, value: 120.0, date: Date()),      // 120 kg
                PersonalRecord(exerciseName: "Deadlift", recordType: .oneRepMax, value: 150.0, date: Date()),
                PersonalRecord(exerciseName: "Overhead Press", recordType: .oneRepMax, value: 60.0, date: Date()),
                PersonalRecord(exerciseName: "Barbell Row", recordType: .oneRepMax, value: 80.0, date: Date()),
                PersonalRecord(exerciseName: "Pull Up", recordType: .maxWeight, value: 20.0, date: Date())
            ],
            achievements: (1...10).map { i in
                Achievement(title: "Earned Achievement \(i)", description: "Description \(i)", iconName: "star.fill", isEarned: true, earnedDate: Date())
            } + (1...10).map { i in
                Achievement(title: "Unearned Achievement \(i)", description: "Description \(i)", iconName: "lock.fill", isEarned: false)
            },
            watchedExercises: ["Bench Press"]
        )

        return NavigationView {
            AchievementsView(userProfile: $sampleProfile)
        }
    }
}
