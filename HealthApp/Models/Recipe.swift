import Foundation

struct Recipe: Identifiable, Codable {
    var id: String { uri }
    let uri: String
    let label: String
    let image: String?
    let url: String
    let calories: Double
    let totalWeight: Double
    let dietLabels: [String]
    let healthLabels: [String]
    let ingredientLines: [String]
    let mealType: [String]
    let totalNutrients: Nutrients?

    struct Nutrients: Codable {
        let ENERC_KCAL: NutrientDetail?
        let FAT: NutrientDetail?
        let CHOCDF: NutrientDetail?
        let PROCNT: NutrientDetail?

        struct NutrientDetail: Codable {
            let label: String
            let quantity: Double
            let unit: String
        }
    }
}
