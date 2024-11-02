import Foundation

struct RecipeList: Codable {
    let meals: [Recipe]  // The array of recipes returned
    let nextLink: String?  // The link for fetching the next batch of recipes
}

struct Recipe: Identifiable, Codable {
    var id: String { url }  // Unique identifier (could be label or URL)
    
    let label: String
    let image: String?
    let url: String
    let calories: Double
    let totalWeight: Double
    let yield: Double?  // Optional yield for serving size
    let totalTime: Double?  // Optional total time
    let dietLabels: [String]
    let healthLabels: [String]
    let ingredientLines: [String]
    let mealType: [String]
    let totalNutrients: Nutrients?

    struct Nutrients: Codable {
        let ENERC_KCAL: NutrientDetail? // Calories
        let FAT: NutrientDetail?        // Fat
        let CHOCDF: NutrientDetail?     // Carbs
        let PROCNT: NutrientDetail?     // Protein

        struct NutrientDetail: Codable {
            let label: String
            let quantity: Double
            let unit: String
        }
    }
}
