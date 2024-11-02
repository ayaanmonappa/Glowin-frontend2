import Foundation

struct Measurement: Codable, Identifiable {
    var id: UUID?
    var userID: UUID
    var weight: Double
    var height: Double
    var bicep: Double
    var calf: Double
    var waist: Double
    var thigh: Double
    var chest: Double
    var date: Date  // No change here, keeping Date type for "date"

    // This is the public representation of the Measurement
    struct MeasurementPublic: Codable, Identifiable, Equatable {
        var id: UUID?
        var userID: UUID
        var weight: Double
        var height: Double
        var bicep: Double
        var calf: Double
        var waist: Double
        var thigh: Double
        var chest: Double
        var date: Date

        // Default initializer
        init(id: UUID? = nil, userID: UUID, weight: Double, height: Double, bicep: Double, calf: Double, waist: Double, thigh: Double, chest: Double, date: Date) {
            self.id = id
            self.userID = userID
            self.weight = weight
            self.height = height
            self.bicep = bicep
            self.calf = calf
            self.waist = waist
            self.thigh = thigh
            self.chest = chest
            self.date = date
        }

        // Equatable conformance for better comparisons
        static func == (lhs: MeasurementPublic, rhs: MeasurementPublic) -> Bool {
            return lhs.id == rhs.id &&
                lhs.userID == rhs.userID &&
                lhs.weight == rhs.weight &&
                lhs.height == rhs.height &&
                lhs.bicep == rhs.bicep &&
                lhs.calf == rhs.calf &&
                lhs.waist == rhs.waist &&
                lhs.thigh == rhs.thigh &&
                lhs.chest == rhs.chest &&
                lhs.date == rhs.date
        }
    }

    // Function to return the public representation
    func toPublic() -> MeasurementPublic {
        return MeasurementPublic(
            id: self.id,
            userID: self.userID,
            weight: self.weight,
            height: self.height,
            bicep: self.bicep,
            calf: self.calf,
            waist: self.waist,
            thigh: self.thigh,
            chest: self.chest,
            date: self.date
        )
    }
}
