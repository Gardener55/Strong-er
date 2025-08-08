import Foundation
import Combine

class UserProfileService: ObservableObject {
    private static let userProfileKey = "userProfile"

    @Published var userProfile: UserProfile {
        didSet {
            saveProfile()
        }
    }

    init() {
        self.userProfile = UserProfileService.loadProfile()
    }

    private static func loadProfile() -> UserProfile {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: userProfileKey) {
            let decoder = JSONDecoder()
            if let profile = try? decoder.decode(UserProfile.self, from: data) {
                return profile
            }
        }
        return UserProfile()
    }

    func saveProfile() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(userProfile) {
            defaults.set(data, forKey: UserProfileService.userProfileKey)
        }
    }
}
