import Foundation

struct WorkoutDay: Identifiable, Codable {
    let id = UUID()
    let dayName: String
    let exercises: [WorkoutExercise]
}

struct WorkoutExercise: Identifiable, Codable {
    let id = UUID()
    let exerciseName: String
    let bodyPart: String
    let sets: Int
    let reps: Int
    let gifUrl: String?
}
