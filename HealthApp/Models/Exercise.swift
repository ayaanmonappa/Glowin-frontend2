import Foundation

struct Exercise: Codable, Identifiable {
    let id: String
    let name: String
    let bodyPart: String
    let equipment: String
    let target: String
    let gifUrl: String
    let secondaryMuscles: [String]?
    let instructions: [String]?
}
