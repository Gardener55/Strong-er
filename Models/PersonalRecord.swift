import Foundation

struct PersonalRecord: Identifiable, Codable, Equatable {
    var id = UUID()
    var exerciseName: String
    var recordType: RecordType
    var value: Double
    var date: Date

    enum RecordType: String, Codable, CaseIterable {
        case oneRepMax = "1 Rep Max"
        case maxWeight = "Max Weight"
        case maxVolume = "Max Volume" // Volume = weight * reps * sets
    }
}
