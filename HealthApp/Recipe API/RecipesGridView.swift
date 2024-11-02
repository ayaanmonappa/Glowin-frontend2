import SwiftUI

struct RecipesGridView: View {
    @State private var recipes: [Recipe] = []
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var searchQuery: String = ""
    @State private var mealType: String = "Dinner"
    @State private var ingredient: String = ""
    let user: UserDetails
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search Recipes", text: $searchQuery, onCommit: {
                        fetchRecipes(query: searchQuery)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                    TextField("Ingredient", text: $ingredient, onCommit: {
                        fetchRecipes(query: searchQuery)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                }

                Picker("Meal Type", selection: $mealType) {
                    Text("Breakfast").tag("Breakfast")
                    Text("Lunch").tag("Lunch")
                    Text("Dinner").tag("Dinner")
                    Text("Snack").tag("Snack")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if isLoading {
                    ProgressView("Fetching Recipes...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                            ForEach(recipes, id: \.label) { recipe in
                                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                    RecipePreview(recipe: recipe)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recipe Bank")
        }
    }
    
    private func fetchRecipes(query: String) {
        isLoading = true
        
        let caloricNeeds = calculateCaloricNeeds(user: user)
        let nutritionalNeeds = calculateNutritionalNeeds(user: user)
        let caloriesRange = "\(Int(caloricNeeds - 200))-\(Int(caloricNeeds + 200))"
        let proteinRange = "\(Int(nutritionalNeeds.protein * 0.9))-\(Int(nutritionalNeeds.protein * 1.1))"
        let fatRange = "\(Int(nutritionalNeeds.fat * 0.9))-\(Int(nutritionalNeeds.fat * 1.1))"
        let carbsRange = "\(Int(nutritionalNeeds.carbs * 0.9))-\(Int(nutritionalNeeds.carbs * 1.1))"
        
        RecipeService().To create a fully functional recipe recommendation system that takes into account both caloric and nutritional needs, we'll use accurate data on macronutrient intake. This includes different goals like muscle gain, fat loss, and maintenance, while also integrating user-specific information such as gender, age, weight, height, activity level, and body type. Below is a detailed implementation including all required components.

### Nutritional Needs Calculation

The protein, fat, and carbohydrate requirements will be determined based on the user's goals. Here's a breakdown of optimal intake:

1. **Muscle Gain**:
   - Protein: 1.6 - 2.4 g/kg of body weight
   - Fat: 25 - 30% of total caloric intake
   - Carbs: Remaining calories

2. **Fat Loss**:
   - Protein: 2.3 - 3.1 g/kg of body weight
   - Fat: 25 - 30% of total caloric intake
   - Carbs: Remaining calories

3. **Maintenance**:
   - Protein: 1.2 - 1.5 g/kg of body weight
   - Fat: 25 - 30% of total caloric intake
   - Carbs: Remaining calories

These values are derived from various sources and recommended by the International Society of Sports Nutrition (ISSN)【501†source】 .

### Utility Functions

Let's start by defining utility functions to calculate caloric and nutritional needs based on the user details.

```swift
import Foundation

struct UserDetails {
    var gender: String
    var age: Int
    var weight: Double
    var height: Double
    var activityLevel: String
    var goalType: String
    var bodyType: String
}

func calculateCaloricNeeds(user: UserDetails) -> Double {
    let bmr: Double
    if user.gender.lowercased() == "male" {
        bmr = 10 * user.weight + 6.25 * user.height - 5 * user.age + 5
    } else {
        bmr = 10 * user.weight + 6.25 * user.height - 5 * user.age - 161
    }

    let tdee: Double
    switch user.activityLevel.lowercased() {
    case "sedentary":
        tdee = bmr * 1.2
    case "lightly active":
        tdee = bmr * 1.375
    case "moderately active":
        tdee = bmr * 1.55
    case "very active":
        tdee = bmr * 1.725
    case "super active":
        tdee = bmr * 1.9
    default:
        tdee = bmr * 1.2
    }

    switch user.goalType.lowercased() {
    case "lose weight":
        return tdee - 500
    case "gain muscle":
        return tdee + 500
    default:
        return tdee
    }
}

func calculateNutritionalNeeds(user: UserDetails) -> (protein: Double, fat: Double, carbs: Double) {
    let proteinPerKg: Double
    let fatPercentage: Double = 0.3
    let carbsPercentage: Double = 0.5

    switch user.goalType.lowercased() {
    case "lose weight":
        proteinPerKg = 2.3 // 2.3-3.1 g/kg for optimal fat loss and muscle preservation
    case "gain muscle":
        proteinPerKg = 1.6 // 1.6-2.4 g/kg for muscle gain
    default:
        proteinPerKg = 1.2 // 1.2-1.5 g/kg for maintenance
    }

    let protein = proteinPerKg * user.weight
    let calories = calculateCaloricNeeds(user: user)
    let fat = (calories * fatPercentage) / 9
    let carbs = (calories * carbsPercentage) / 4

    return (protein, fat, carbs)
}
