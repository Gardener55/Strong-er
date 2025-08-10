import SwiftUI

struct PostWorkoutSummaryView: View {
    let workout: Workout
    let summaryData: (brokenPRs: [PersonalRecord], newAchievements: [Achievement])
    let dismissAction: () -> Void

    @EnvironmentObject var userProfileService: UserProfileService

    var body: some View {
        VStack(spacing: 20) {
            Text("Workout Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            // Workout Stats Section
            VStack(alignment: .leading, spacing: 8) {
                Text(workout.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text("Duration: \(formatDuration(workout.duration ?? 0))")
                    .font(.headline)
                // I can add more stats here later if needed
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)

            ScrollView {
                // PRs Section
                if !summaryData.brokenPRs.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("New Personal Records!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        ForEach(summaryData.brokenPRs) { pr in
                            VStack(alignment: .leading) {
                                Text(pr.exerciseName).font(.headline)
                                Text("\(pr.recordType.rawValue): \(String(format: "%.1f", pr.value))")
                                    .font(.subheadline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }

                // Achievements Section
                if !summaryData.newAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Achievements Unlocked!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        ForEach(summaryData.newAchievements) { achievement in
                            VStack(alignment: .leading) {
                                Text(achievement.title).font(.headline)
                                Text(achievement.description(for: userProfileService.userProfile.weightUnit))
                                    .font(.subheadline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
            }

            Spacer()

            Button("Done") {
                dismissAction()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(10)
        }
        .padding()
        .navigationBarHidden(true)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}
