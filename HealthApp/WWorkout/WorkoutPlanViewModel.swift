import Foundation
import Combine
import SwiftUI

class WorkoutPlanViewModel: ObservableObject {
    @Published var workoutPlan: [WorkoutDay] = []
    @Published var selectedSplit: Int = 3 // Default to 3-day split
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()
    private let exerciseService = ExerciseService()

    func generateWorkoutPlan(for user: User) {
        // You can customize the logic here based on the user's preferences, goals, and selected split
        switch selectedSplit {
        case 3:
            generate3DaySplit(for: user)
        case 4:
            generate4DaySplit(for: user)
        case 5:
            generate5DaySplit(for: user)
        default:
            break
        }
    }

    private func generate3DaySplit(for user: User) {
        exerciseService.fetchExercises(bodyPart: "chest")
            .combineLatest(exerciseService.fetchExercises(bodyPart: "back"),
                           exerciseService.fetchExercises(bodyPart: "legs"))
            .map { chestExercises, backExercises, legExercises in
                return [
                    WorkoutDay(dayName: "Day 1: Chest & Triceps", exercises: self.selectExercises(from: chestExercises + backExercises, count: 6)),
                    WorkoutDay(dayName: "Day 2: Back & Biceps", exercises: self.selectExercises(from: backExercises, count: 6)),
                    WorkoutDay(dayName: "Day 3: Legs & Shoulders", exercises: self.selectExercises(from: legExercises, count: 6))
                ]
            }
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { workoutDays in
                self.workoutPlan = workoutDays
            })
            .store(in: &cancellables)
    }

    private func generate4DaySplit(for user: User) {
        // Add logic for a 4-day split
    }

    private func generate5DaySplit(for user: User) {
        // Add logic for a 5-day split
    }

    private func selectExercises(from exercises: [Exercise], count: Int) -> [WorkoutExercise] {
        return Array(exercises.shuffled().prefix(count)).map { exercise in
            WorkoutExercise(exerciseName: exercise.name, bodyPart: exercise.bodyPart, sets: 3, reps: 10, gifUrl: exercise.gifUrl)
        }
    }
}
