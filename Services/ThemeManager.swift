import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { self.rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

class ThemeManager: ObservableObject {
    @AppStorage("theme") var selectedTheme: Theme = .system

    func applyTheme() {
        // This function is a placeholder for now.
        // The actual theme application will be done in the main App file.
    }
}
