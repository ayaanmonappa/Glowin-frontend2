import SwiftUI

struct LineGraphView: View {
    var measurements: [Measurement.MeasurementPublic]
    var selectedMeasurement: String
    var goals: [GeneratedGoal.GoalPublic]

    var body: some View {
        VStack {
            if let dataPoints = dataPointsForMeasurement(measurements: measurements, selectedMeasurement: selectedMeasurement) {
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        let maxDataPoint = dataPoints.max() ?? 1
                        let minDataPoint = dataPoints.min() ?? 0

                        let stepX = width / CGFloat(dataPoints.count - 1)
                        let stepY = height / CGFloat(maxDataPoint - minDataPoint)

                        path.move(to: CGPoint(x: 0, y: height - CGFloat(dataPoints[0] - minDataPoint) * stepY))

                        for i in 1..<dataPoints.count {
                            let point = CGPoint(x: CGFloat(i) * stepX, y: height - CGFloat(dataPoints[i] - minDataPoint) * stepY)
                            path.addLine(to: point)
                        }
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
                .frame(height: 200)
                .background(Color.gray.opacity(0.2))

                Text("Goal: \(goalForMeasurement(goals: goals, selectedMeasurement: selectedMeasurement) ?? 0)")
                    .font(.headline)
                    .padding(.top, 8)
            } else {
                Text("No data available for \(selectedMeasurement).")
            }
        }
    }

    private func dataPointsForMeasurement(measurements: [Measurement.MeasurementPublic], selectedMeasurement: String) -> [Double]? {
        switch selectedMeasurement.lowercased() {
        case "weight":
            return measurements.map { $0.weight }
        case "height":
            return measurements.map { $0.height }
        case "bicep":
            return measurements.map { $0.bicep }
        case "calf":
            return measurements.map { $0.calf }
        case "waist":
            return measurements.map { $0.waist }
        case "thigh":
            return measurements.map { $0.thigh }
        case "chest":
            return measurements.map { $0.chest }
        default:
            return nil
        }
    }

    private func goalForMeasurement(goals: [GeneratedGoal.GoalPublic], selectedMeasurement: String) -> Double? {
        return goals.first(where: { $0.measurementType.lowercased() == selectedMeasurement.lowercased() })?.goalValue
    }
}

struct LineGraphView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMeasurements = [
            Measurement.MeasurementPublic(weight: 70, height: 170, bicep: 30, calf: 40, waist: 80, thigh: 50, chest: 100, date: Date()),
            Measurement.MeasurementPublic(weight: 72, height: 170, bicep: 31, calf: 41, waist: 82, thigh: 52, chest: 101, date: Date()),
            Measurement.MeasurementPublic(weight: 71, height: 170, bicep: 32, calf: 42, waist: 81, thigh: 51, chest: 102, date: Date())
        ]
        let sampleGoals = [
            GeneratedGoal.GoalPublic(measurementType: "Weight", goalValue: 68, targetDate: Date())
        ]

        LineGraphView(measurements: sampleMeasurements, selectedMeasurement: "Weight", goals: sampleGoals)
    }
}
