import SwiftUI

struct RecipeView: View {
    let recipes = [
        "Grilled Chicken Salad",
        "Vegetable Stir Fry",
        "Quinoa and Black Bean Bowl",
        "Baked Salmon with Asparagus",
        "Smoothie Bowl"
    ]
    
    var body: some View {
        NavigationView {
            List(recipes, id: \.self) { recipe in
                Text(recipe)
            }
            .navigationTitle("Recipes")
        }
    }
}

struct RecipeView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeView()
    }
}
