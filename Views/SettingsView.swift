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
    @State private var isExporting = false
    @State private var exportError: Error?
    @State private var exportedFileURL: URL?
    @State private var healthKitConnected = false
    @State private var showHealthKitAlert = false

    private let workoutImporter = WorkoutImporter()
    private let workoutExporter = WorkoutExporter()
    private let healthKitManager = HealthKitManager()

    private func importWorkouts(from url: URL, as sourceUnit: UserProfile.WeightUnit) {
        do {
            try workoutImporter.importWorkouts(from: url, exerciseDatabase: exerciseDatabase, workoutManager: workoutManager, sourceUnit: sourceUnit)
        } catch {
            importError = error
            showError = true
        }
    }

    private func downloadTemplate() {
        if let url = Bundle.main.url(forResource: "workout_template", withExtension: "csv") {
            exportedFileURL = url
            isExporting = true
        } else {
            exportError = NSError(domain: "WorkoutApp", code: 404, userInfo: [NSLocalizedDescriptionKey: "Template file not found."])
            showError = true
        }
    }

    private func exportWorkouts() {
        do {
            exportedFileURL = try workoutExporter.exportWorkouts(workoutManager: workoutManager)
            isExporting = true
        } catch {
            exportError = error
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

                    Picker("Height", selection: $userProfileService.userProfile.heightUnit) {
                        ForEach(UserProfile.HeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Workout Settings")) {
                    Stepper(value: $userProfileService.userProfile.defaultRestTimer, in: 0...300, step: 5) {
                        Text("Default Rest Timer: \(Int(userProfileService.userProfile.defaultRestTimer)) seconds")
                    }
                }

                Section(header: Text("Data Management")) {
                    Button("Import Workouts from CSV") {
                        isImporting = true
                    }
                    .buttonStyle(HapticButtonStyle())

                    Button("Export Workout Data") {
                        exportWorkouts()
                    }
                    .buttonStyle(HapticButtonStyle())

                    Button("Download Template File") {
                        downloadTemplate()
                    }
                    .buttonStyle(HapticButtonStyle())
                }

                Section(header: Text("Apple Health")) {
                    Button(healthKitConnected ? "Connected to Apple Health" : "Connect to Apple Health") {
                        if !healthKitConnected {
                            healthKitManager.requestAuthorization { success, error in
                                DispatchQueue.main.async {
                                    if success {
                                        healthKitConnected = true
                                    }
                                    showHealthKitAlert = true
                                }
                            }
                        }
                    }
                    .buttonStyle(HapticButtonStyle())
                    .disabled(healthKitConnected)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                healthKitConnected = healthKitManager.checkAuthorizationStatus()
            }
            .alert(isPresented: $showHealthKitAlert) {
                Alert(
                    title: Text(healthKitConnected ? "Success" : "Error"),
                    message: Text(healthKitConnected ? "Successfully connected to Apple Health." : "Failed to connect to Apple Health. Please make sure you have granted the necessary permissions in the Health app."),
                    dismissButton: .default(Text("OK"))
                )
            }
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
            .sheet(isPresented: $isExporting) {
                if let url = exportedFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(exportError?.localizedDescription ?? importError?.localizedDescription ?? "An unknown error occurred."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {}
}
