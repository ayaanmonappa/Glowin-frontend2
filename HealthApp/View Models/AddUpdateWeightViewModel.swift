import SwiftUI

final class AddUpdateMeasurementViewModel: ObservableObject {
    @Published var weight: Double = 0
    @Published var height: Double = 0
    @Published var bicep: Double = 0
    @Published var calf: Double = 0
    @Published var waist: Double = 0
    @Published var thigh: Double = 0
    @Published var chest: Double = 0
    @Published var selectedDate: Date = Date()
    
    var measurementID: UUID? = nil
    
    var isUpdating: Bool {
        return measurementID != nil
    }
    
    var buttonTitle: String {
        return measurementID != nil ? "Update Measurement" : "Add Measurement"
    }
    
    init() {}
    
    init(currentMeasurement: Measurement) {
        self.measurementID = currentMeasurement.id
        self.weight = currentMeasurement.weight
        self.height = currentMeasurement.height
        self.bicep = currentMeasurement.bicep
        self.calf = currentMeasurement.calf
        self.waist = currentMeasurement.waist
        self.thigh = currentMeasurement.thigh
        self.chest = currentMeasurement.chest
        self.selectedDate = currentMeasurement.date
    }
    
    func addMeasurement(userID: UUID) async throws {
        let urlString = constants.baseURL + "/measurements"
        
        guard let url = URL(string: urlString) else {
            throw HttpError.badURL
        }
        
        let measurement = Measurement(
            id: nil,
            userID: userID,
            weight: weight,
            height: height,
            bicep: bicep,
            calf: calf,
            waist: waist,
            thigh: thigh,
            chest: chest,
            date: selectedDate
        )
        
        try await HttpClient.shared.sendData(to: url, object: measurement, httpMethod: "POST")
    }
    
    func updateMeasurement(userID: UUID) async throws {
        let urlString = constants.baseURL + "/measurements/\(measurementID!.uuidString)"
        
        guard let url = URL(string: urlString) else {
            throw HttpError.badURL
        }
        
        let measurement = Measurement(
            id: measurementID,
            userID: userID,
            weight: weight,
            height: height,
            bicep: bicep,
            calf: calf,
            waist: waist,
            thigh: thigh,
            chest: chest,
            date: selectedDate
        )
        
        try await HttpClient.shared.sendData(to: url, object: measurement, httpMethod: "PUT")
    }
    
    func addUpdateAction(userID: UUID, completion: @escaping () -> Void) {
        Task {
            do {
                if isUpdating {
                    try await updateMeasurement(userID: userID)
                } else {
                    try await addMeasurement(userID: userID)
                }
            } catch {
                print("ERROR: \(error)")
            }
            completion()
        }
    }
}
