import SwiftUI

struct RecipeDetailView: View {
    var recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let imageURL = recipe.image, let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        } else if phase.error != nil {
                            Text("Failed to load image")
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(height: 200)
                }

                Text(recipe.label)
                    .font(.title)
                    .padding(.top, 10)

                Text("Calories: \(Int(recipe.calories)) kcal")
                    .font(.subheadline)
                    .padding(.top, 5)

                if let yield = recipe.yield {
                    Text("Servings: \(Int(yield))")
                        .font(.subheadline)
                        .padding(.top, 5)
                }

                if !recipe.ingredientLines.isEmpty {
                    Text("Ingredients")
                        .font(.headline)
                        .padding(.top, 10)
                    ForEach(recipe.ingredientLines, id: \.self) { ingredient in
                        Text("• \(ingredient)")
                            .padding(.top, 2)
                    }
                }

                if let nutrients = recipe.totalNutrients {
                    Text("Nutritional Information")
                        .font(.headline)
                        .padding(.top, 10)

                    if let protein = nutrients.PROCNT {
                        Text("Protein: \(protein.quantity, specifier: "%.1f") \(protein.unit)")
                            .padding(.top, 2)
                    }
                    if let fat = nutrients.FAT {
                        Text("Fat: \(fat.quantity, specifier: "%.1f") \(fat.unit)")
                            .padding(.top, 2)
                    }
                    if let carbs = nutrients.CHOCDF {
                        Text("Carbs: \(carbs.quantity, specifier: "%.1f") \(carbs.unit)")
                            .padding(.top, 2)
                    }
                }

                if let sourceURL = URL(string: recipe.url) {
                    Link("View Full Recipe", destination: sourceURL)
                        .padding(.top, 20)
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
