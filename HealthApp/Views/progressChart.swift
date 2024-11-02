import SwiftUI
import Charts

struct ProgressChart: View {
    let measurements: [Measurement.MeasurementPublic]
    let goals: [GeneratedGoal.GoalPublic]
    let selectedMeasurement: String

    var body: some View {
        VStack {
            Chart {
                // Plot the user's measurement progress
                ForEach(measurements) { measurement in
                    LineMark(
                        x: .value("Date", measurement.date, unit: .month),
                        y: .value(selectedMeasurement, getMeasurementValue(for: measurement))
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", measurement.date, unit: .month),
                        y: .value(selectedMeasurement, getMeasurementValue(for: measurement))
                    )
                    .annotation(position: .top) {
                        Text("\(getMeasurementValue(for: measurement), specifier: "%.2f")")
                            .font(.caption)
                            .padding(4)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(4)
                    }
                }

                // Add a goal line if a matching goal is found
                if let goal = goals.first(where: { $0.measurementType.lowercased() == selectedMeasurement.lowercased() }) {
                    RuleMark(
                        y: .value("Goal", goal.goalValue)
                    )
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                    .annotation(position: .topTrailing) {
                        Text("Goal: \(goal.goalValue, specifier: "%.2f")")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month))
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .padding()

            Text("Rotate for better view")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
        }
    }

    private func getMeasurementValue(for measurement: Measurement.MeasurementPublic) -> Double {
        switch selectedMeasurement.lowercased() {
        case "weight":
            return measurement.weight
        case "bicep":
            return measurement.bicep
        case "calf":
            return measurement.calf
        case "waist":
            return measurement.waist
        case "thigh":
            return measurement.thigh
        case "chest":
            return measurement.chest
        default:
            print("Unknown measurement type: \(selectedMeasurement)")
            return 0.0
        }
    }
}
