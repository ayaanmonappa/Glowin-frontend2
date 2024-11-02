import SwiftUI

struct ExerciseSearchView: View {
    @ObservedObject var viewModel: WorkoutPlanViewModel
    @State private var searchQuery: String = ""
    
    var body: some View {
        VStack {
            TextField("Search by body part", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Search") {
                viewModel.fetchExercises(by: searchQuery)
            }
            .padding()

            List(viewModel.filteredExercises) { exercise in
                VStack(alignment: .leading) {
                    Text(exercise.name)
                        .font(.headline)
                    Text("Body Part: \(exercise.bodyPart)")
                        .font(.subheadline)
                    if let gifUrl = exercise.gifUrl {
                        AsyncImage(url: URL(string: gifUrl))
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Search Exercises")
    }
}
