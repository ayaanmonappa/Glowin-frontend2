import SwiftUI

struct WorkoutDetailView: View {
    let workoutDay: WorkoutDay

    var body: some View {
        List(workoutDay.exercises, id: \.id) { exercise in
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                Text("Target: \(exercise.target)")
                Text("Equipment: \(exercise.equipment)")
                if let reps = exercise.recommendedReps {
                    Text("Recommended Reps: \(reps)")
                }
                if let gifUrl = exercise.gifUrl, let url = URL(string: gifUrl) {
                    GIFView(url: url)
                        .frame(height: 200)
                        .cornerRadius(10)
                }
            }
            .padding(.vertical, 5)
        }
        .navigationTitle(workoutDay.dayName)
    }
}

// Placeholder GIF view
struct GIFView: View {
    let url: URL

    var body: some View {
        Text("GIF Placeholder")
        // Replace this with actual GIF handling using a WebView or third-party library
    }
}
