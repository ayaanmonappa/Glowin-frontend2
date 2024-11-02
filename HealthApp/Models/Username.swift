import SwiftUI

struct User: Codable {
    var username: String
    var email: String
    var password: String
    var gender: String
    var age: Int
    var bodyType: String?  // Ectomorph, Mesomorph, Endomorph
    var activityLevel: String?  // Sedentary, Lightly Active, Moderately Active, Very Active, Super Active
    var lastGoalGeneration: Date?

    init(username: String, email: String, password: String, gender: String, age: Int, bodyType: String? = nil, activityLevel: String? = nil, lastGoalGeneration: Date? = nil) {
        self.username = username
        self.email = email
        self.password = password
        self.gender = gender
        self.age = age
        self.bodyType = bodyType
        self.activityLevel = activityLevel
        self.lastGoalGeneration = lastGoalGeneration
    }
}
