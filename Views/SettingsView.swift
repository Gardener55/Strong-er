import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var exerciseDatabase: ExerciseDatabase
    @EnvironmentObject var userProfileService: UserProfileService

    @State private var isImporting = false
    @State private var importError: Error?
    @State private var showError = false

    private let workoutImporter = WorkoutImporter()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $themeManager.selectedTheme) {
                        ForEach(Theme.allCases) { theme in
                            Text(theme.rawValue.capitalized).tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Units")) {
                    Picker("Weight", selection: $userProfileService.userProfile.weightUnit) {
                        ForEach(UserProfile.WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Data Management")) {
                    Button("Import Workouts from CSV") {
                        isImporting = true
                    }
                }
            }
            .navigationTitle("Settings")
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [UTType.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                do {
                    guard let selectedFile: URL = try result.get().first else { return }
                    try workoutImporter.importWorkouts(from: selectedFile, exerciseDatabase: exerciseDatabase, workoutManager: workoutManager)
                } catch {
                    importError = error
                    showError = true
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Import Error"),
                    message: Text(importError?.localizedDescription ?? "An unknown error occurred."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
