import Foundation

struct GeneratedGoal: Codable, Identifiable {
    var id: UUID?
    var userID: UUID
    var measurementType: String
    var goalValue: Double
    var targetDate: Date
    var dateGenerated: Date

    struct GoalPublic: Codable, Identifiable {
        var id: UUID
        var measurementType: String
        var goalValue: Double
        var targetDate: String  // Expect String
        var dateGenerated: String  // Expect String

        init(id: UUID = UUID(), measurementType: String, goalValue: Double, targetDate: String, dateGenerated: String) {
            self.id = id
            self.measurementType = measurementType
            self.goalValue = goalValue
            self.targetDate = targetDate
            self.dateGenerated = dateGenerated
        }
    }

    func toPublic() -> GoalPublic {
        let dateFormatter = ISO8601DateFormatter()
        return GoalPublic(
            id: self.id ?? UUID(),
            measurementType: self.measurementType,
            goalValue: self.goalValue,
            targetDate: dateFormatter.string(from: self.targetDate),
            dateGenerated: dateFormatter.string(from: self.dateGenerated)
        )
    }
}
