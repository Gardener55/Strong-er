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
    @State private var showingUnitSelector = false
    @State private var selectedFile: URL?

    private let workoutImporter = WorkoutImporter()

    private func importWorkouts(from url: URL, as sourceUnit: UserProfile.WeightUnit) {
        do {
            try workoutImporter.importWorkouts(from: url, exerciseDatabase: exerciseDatabase, workoutManager: workoutManager, sourceUnit: sourceUnit)
        } catch {
            importError = error
            showError = true
        }
    }

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
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    self.selectedFile = url
                    self.showingUnitSelector = true
                case .failure(let error):
                    self.importError = error
                    self.showError = true
                }
            }
            .confirmationDialog(
                "Select the weight unit of the data in your CSV file.",
                isPresented: $showingUnitSelector,
                titleVisibility: .visible
            ) {
                Button("Kilograms (kg)") {
                    if let url = selectedFile {
                        importWorkouts(from: url, as: .kilograms)
                    }
                }
                Button("Pounds (lbs)") {
                    if let url = selectedFile {
                        importWorkouts(from: url, as: .pounds)
                    }
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
