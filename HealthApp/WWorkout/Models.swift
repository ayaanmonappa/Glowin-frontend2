import Foundation

struct WorkoutDay: Identifiable, Codable {
    let id = UUID()
    let dayName: String
    let exercises: [WorkoutExercise]
    let targetMuscles: [String]
}

struct WorkoutExercise: Identifiable, Codable {
    let id = UUID()
    let name: String
    let target: String
    let equipment: String
    let gifUrl: String?
    let recommendedReps: String?

    init(from response: ExerciseResponse) {
        self.name = response.name
        self.target = response.target
        self.equipment = response.equipment
        self.gifUrl = response.gifUrl
        self.recommendedReps = "8-12 reps" // Example, could be dynamic based on user goal
    }
}

struct ExerciseResponse: Codable {
    let bodyPart: String
    let equipment: String
    let gifUrl: String
    let id: String
    let name: String
    let target: String
    let secondaryMuscles: [String]
    let instructions: [String]
}
